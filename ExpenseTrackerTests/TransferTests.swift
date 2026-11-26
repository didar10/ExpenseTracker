import Foundation
import SwiftData
import Testing
@testable import ExpenseTracker

@MainActor
struct TransferTests {
    private let context: ModelContext
    private let from = Account(name: "Карта", initialBalance: 1_000)
    private let to = Account(name: "Наличные", initialBalance: 100)
    private let third = Account(name: "Вклад", initialBalance: 50)
    private let day = Date.now

    init() throws {
        context = ModelContext(try AppModelContainer.make(inMemory: true))
        context.insert(from)
        context.insert(to)
        context.insert(third)
        try context.save()
    }

    private var repository: SwiftDataTransactionRepository {
        SwiftDataTransactionRepository(context: context)
    }

    private func addTransfer(_ amount: Decimal) throws -> Transaction {
        try repository.add(TransactionDraft(amount: amount, date: day, fromAccount: from, toAccount: to))
    }

    @Test func transferChangesBothBalancesButNotTotalAndMayGoNegative() throws {
        let transfer = try addTransfer(1_250)
        #expect(transfer.kind == .transfer)
        #expect(transfer.category == nil)
        #expect(from.currentBalance == -250)
        #expect(to.currentBalance == 1_350)
        #expect(BalanceData(accounts: [from, to, third]).balance == 1_150)
        #expect(from.totalExpenses == 0)
        #expect(to.totalIncome == 0)
        #expect(transfer.involves(from))
        #expect(transfer.involves(to))
        #expect(!transfer.involves(third))
    }

    @Test func rejectsInvalidTransfersBeforeWriting() throws {
        #expect(throws: TransferValidationError.nonPositiveAmount) { try addTransfer(0) }
        #expect(throws: TransferValidationError.nonPositiveAmount) { try addTransfer(-100) }
        #expect(throws: TransferValidationError.nonPositiveAmount) { try addTransfer(.nan) }
        #expect(throws: TransferValidationError.sameAccount) {
            try repository.add(TransactionDraft(amount: 100, date: day, fromAccount: from, toAccount: from))
        }
        #expect(throws: TransferValidationError.unavailableAccount) {
            try repository.add(TransactionDraft(amount: 100, date: day, fromAccount: from, toAccount: Account(name: "Не сохранен")))
        }
        #expect(try context.fetchCount(FetchDescriptor<Transaction>()) == 0)
        #expect(from.currentBalance == 1_000)
        #expect(to.currentBalance == 100)
    }

    @Test func editingAndUndoRestoreTheRightAccounts() throws {
        let transfer = try addTransfer(250)
        let invalid = TransactionDraft(amount: 100, date: day, fromAccount: to, toAccount: to)
        #expect(throws: TransferValidationError.sameAccount) { try repository.update(transfer, with: invalid) }
        #expect(from.currentBalance == 750)
        #expect(to.currentBalance == 350)

        try repository.update(transfer, with: TransactionDraft(amount: 50, date: day, fromAccount: to, toAccount: third))
        #expect(from.currentBalance == 1_000)
        #expect(to.currentBalance == 50)
        #expect(third.currentBalance == 100)

        let draft = TransactionDraft(transfer)
        try repository.delete(transfer)
        #expect(to.currentBalance == 100)
        #expect(third.currentBalance == 50)
        try repository.add(draft)
        #expect(to.currentBalance == 50)
        #expect(third.currentBalance == 100)
    }

    @Test(arguments: [true, false])
    func deletingEitherAccountRemovesBothSidesOfTransfer(deletesSource: Bool) throws {
        _ = try addTransfer(250)
        let deleted = deletesSource ? from : to
        let surviving = deletesSource ? to : from
        try SwiftDataAccountRepository(context: context).delete(deleted)

        #expect(try context.fetchCount(FetchDescriptor<Transaction>()) == 0)
        #expect(surviving.currentBalance == surviving.initialBalance)
    }

    @Test func transferIsExcludedFromDashboardStatisticsBudgetAndAllowance() throws {
        let category = ExpenseTracker.Category(name: "Еда", icon: "basket", colorHex: "#8EE3A1")
        let incomeCategory = ExpenseTracker.Category(name: "Доход", icon: "banknote", colorHex: "#8EE3A1", type: .income)
        context.insert(category)
        context.insert(incomeCategory)

        let income = try repository.add(TransactionDraft(amount: 500, date: day, type: .income, category: incomeCategory, account: from))
        let expense = try repository.add(TransactionDraft(amount: 100, date: day, type: .expense, category: category, account: from))
        let transfer = try addTransfer(250)
        let transactions = [income, expense, transfer]

        let defaults = try #require(UserDefaults(suiteName: UUID().uuidString))
        let limit = MonthlyLimitStore(defaults: defaults)
        limit.setLimit(1_000)
        let selection = AccountSelectionStore()
        selection.selectedAccount = from
        let period = DashboardPeriodStore(defaults: defaults)
        period.select(.month)
        let dashboard = DashboardViewModel(accountSelection: selection, periodStore: period, limitStore: limit)
        let snapshot = dashboard.makeSnapshot(accounts: [from, to, third], transactions: transactions)
        #expect(snapshot.totalBalance == 1_150)
        #expect(snapshot.periodBalance.totalIncome == 500)
        #expect(snapshot.periodBalance.totalExpenses == 100)
        #expect(snapshot.dailyAllowance?.spentToday == 100)
        #expect(snapshot.dailyAllowance?.monthRemaining == 900)
        #expect(TransactionSection(date: day, transactions: transactions).total == 400)

        let statistics = StatisticsViewModel(accountSelection: selection)
        statistics.setup(with: context)
        #expect(statistics.totalAmount == 100)
        #expect(statistics.statistics.count == 1)
        statistics.selectedType = .income
        #expect(statistics.totalAmount == 500)
        #expect(statistics.statistics.count == 1)

        let plan = BudgetPlan(category: category, monthlyLimit: 300)
        context.insert(plan)
        let budgets = BudgetsViewModel(limitStore: limit, now: { day })
        budgets.updateData(budgetPlans: [plan], transactions: transactions)
        #expect(budgets.items.first?.spent == 100)
        #expect(budgets.limitOverview?.spent == 100)
        #expect(budgets.limitOverview?.remaining == 900)
    }
}

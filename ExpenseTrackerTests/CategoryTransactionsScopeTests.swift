import Foundation
import SwiftData
import Testing
@testable import ExpenseTracker

@MainActor
struct CategoryTransactionsScopeTests {
    @Test func keepsOnlySelectedCategoryTypeAccountAndPeriod() throws {
        let context = ModelContext(try AppModelContainer.make(inMemory: true))
        let food = ExpenseTracker.Category(name: "Еда", icon: "basket", colorHex: "#8EE3A1")
        let other = ExpenseTracker.Category(name: "Дом", icon: "house", colorHex: "#D4B5FF")
        let card = Account(name: "Карта")
        let cash = Account(name: "Наличные")
        context.insert(food)
        context.insert(other)
        context.insert(card)
        context.insert(cash)
        try context.save()

        let start = Date(timeIntervalSince1970: 1_794_700_800)
        let end = start.addingTimeInterval(86_400)
        let scope = CategoryTransactionsScope(
            period: .day, interval: DateInterval(start: start, end: end),
            title: AppString.today, type: .expense, accountID: card.persistentModelID
        )
        let rows = [
            Transaction(amount: 850, date: start, type: .expense, category: food, account: card),
            Transaction(amount: 800, date: end, type: .expense, category: food, account: card),
            Transaction(amount: 700, date: start, type: .expense, category: food, account: cash),
            Transaction(amount: 600, date: start, type: .income, category: food, account: card),
            Transaction(amount: 500, date: start, type: .expense, category: other, account: card)
        ]
        #expect(scope.transactions(from: rows, categoryID: food.id).map(\.amount) == [850])
        #expect(scope.totalTitle == AppString.categoryTotalToday)
    }

    @Test func budgetMatchesThePeriodAndPercentUsesDisplayedTotal() {
        let category = ExpenseTracker.Category(name: "Еда", icon: "basket", colorHex: "#8EE3A1")
        let monthly = BudgetPlan(category: category, monthlyLimit: 60_000)
        let weekly = BudgetPlan(category: category, monthlyLimit: 15_000, period: .week)
        let inactive = BudgetPlan(category: category, monthlyLimit: 90_000, isActive: false)
        let plans = [monthly, weekly, inactive]
        let interval = DateInterval(start: .now, duration: 0)
        let month = CategoryTransactionsScope(period: .month, interval: interval, title: "Ноябрь", type: .expense)
        let year = CategoryTransactionsScope(period: .year, interval: interval, title: "2026", type: .expense)

        #expect(month.budget(in: plans) == 60_000)
        #expect(year.budget(in: plans) == nil)
        #expect(CategoryTransactionsScope.budgetPercent(total: 20_650, limit: 60_000) == 34)
        #expect(CategoryTransactionsScope.budgetPercent(total: 0, limit: 60_000) == 0)
        #expect(CategoryTransactionsScope.budgetPercent(total: 0, limit: 0) == nil)
        #expect(month.emptyMessage == AppString.categoryNoMonthlyTransactions)
    }
}

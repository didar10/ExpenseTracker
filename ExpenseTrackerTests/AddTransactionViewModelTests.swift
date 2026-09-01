//
//  AddTransactionViewModelTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 23.08.2026.
//

import Foundation
import SwiftData
import Testing
@testable import ExpenseTracker

@MainActor
struct AddTransactionViewModelTests {

    // MARK: - Helpers

    private func makeContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: Transaction.self, Category.self, Account.self, BudgetPlan.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )

        return ModelContext(container)
    }

    private func transactions(in context: ModelContext) throws -> [Transaction] {
        try context.fetch(FetchDescriptor<Transaction>())
    }

    // MARK: - Tests

    @Test func createsSingleTransaction() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.selectedAccount = account
        viewModel.amount = "250"

        #expect(viewModel.save(using: context))

        let saved = try transactions(in: context)
        #expect(saved.count == 1)
        #expect(saved.first?.amount == 250)
        #expect(saved.first?.type == .expense)
        #expect(account.currentBalance == 750)
    }

    @Test func repeatedSaveDoesNotDuplicateTransaction() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.selectedAccount = account
        viewModel.amount = "250"

        #expect(viewModel.save(using: context))
        #expect(viewModel.save(using: context) == false)
        #expect(viewModel.save(using: context) == false)

        #expect(try transactions(in: context).count == 1)
        #expect(account.currentBalance == 750)
    }

    @Test func enterIsDisabledAfterSave() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.selectedAccount = account
        viewModel.amount = "250"

        #expect(viewModel.isSaveEnabled)

        #expect(viewModel.save(using: context))

        #expect(viewModel.isSaved)
        #expect(viewModel.isSaveEnabled == false)
    }

    @Test func pendingAmountIsClearedAfterSave() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.selectedAccount = account
        viewModel.amount = "250"

        // До сохранения предпросмотр баланса вычитает введённую сумму
        #expect(viewModel.pendingAmount == "250")

        #expect(viewModel.save(using: context))

        // После сохранения сумма уже учтена в currentBalance — вычитать нечего
        #expect(viewModel.pendingAmount.isEmpty)
    }

    @Test func editingUpdatesTransactionWithoutCreatingNewOne() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let transaction = Transaction(amount: 100, date: .now, type: .expense, account: account)
        context.insert(transaction)

        let viewModel = AddTransactionViewModel(transaction: transaction, accountSelection: AccountSelectionStore())
        viewModel.amount = "400"

        #expect(viewModel.save(using: context))

        let saved = try transactions(in: context)
        #expect(saved.count == 1)
        #expect(saved.first?.amount == 400)
        #expect(account.currentBalance == 600)
    }

    // MARK: - Общий выбор счета

    @Test func newTransactionUsesSharedAccountSelection() throws {
        let context = try makeContext()
        let account = Account(name: "Карта", initialBalance: 1000)
        context.insert(account)

        let accountSelection = AccountSelectionStore()
        accountSelection.selectedAccount = account

        let viewModel = AddTransactionViewModel(accountSelection: accountSelection)

        #expect(viewModel.selectedAccount === account)
    }

    @Test func savingMovesSharedSelectionToTransactionAccount() throws {
        let context = try makeContext()
        let card = Account(name: "Карта", initialBalance: 1000)
        let cash = Account(name: "Наличные", initialBalance: 500)
        context.insert(card)
        context.insert(cash)

        let accountSelection = AccountSelectionStore()
        accountSelection.selectedAccount = card

        let viewModel = AddTransactionViewModel(accountSelection: accountSelection)
        viewModel.selectedAccount = cash
        viewModel.amount = "100"

        #expect(viewModel.save(using: context))
        #expect(accountSelection.selectedAccount === cash)
    }

    @Test func savingKeepsAllAccountsMode() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let accountSelection = AccountSelectionStore()

        let viewModel = AddTransactionViewModel(accountSelection: accountSelection)
        viewModel.selectedAccount = account
        viewModel.amount = "100"

        #expect(viewModel.save(using: context))
        #expect(accountSelection.selectedAccount == nil)
    }

    @Test func saveFailsWithZeroAmount() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.selectedAccount = account
        viewModel.amount = "0"

        #expect(viewModel.isSaveEnabled == false)
        #expect(viewModel.save(using: context) == false)
        #expect(try transactions(in: context).isEmpty)
    }

    @Test func saveFailsWithoutValidAmount() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.selectedAccount = account
        viewModel.amount = ""

        #expect(viewModel.save(using: context) == false)
        #expect(viewModel.isSaved == false)
        #expect(try transactions(in: context).isEmpty)
    }

    // MARK: - Ввод суммы

    @Test func amountKeepsAtMostTwoFractionDigits() {
        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())

        for key in ["1", "2"] {
            viewModel.handleKeyTap(.number(key))
        }
        viewModel.handleKeyTap(.decimal)
        for key in ["3", "4", "5"] {
            viewModel.handleKeyTap(.number(key))
        }

        #expect(viewModel.amount == "12.34")
    }

    @Test func amountStopsAtIntegerDigitLimit() {
        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())

        for _ in 0..<20 {
            viewModel.handleKeyTap(.number("9"))
        }

        #expect(viewModel.amount.count == 12)
    }

    @Test func secondDecimalSeparatorIsIgnored() {
        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())

        viewModel.handleKeyTap(.number("5"))
        viewModel.handleKeyTap(.decimal)
        viewModel.handleKeyTap(.decimal)

        #expect(viewModel.amount == "5.")
    }

    @Test func clearAmountRemovesWholeInput() {
        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.amount = "1234"

        viewModel.clearAmount()

        #expect(viewModel.amount.isEmpty)
        #expect(viewModel.hasAmountInput == false)
    }

    @Test func amountDisplayGroupsDigits() {
        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.amount = "1350000.5"

        #expect(viewModel.amountDisplay == "1\u{00A0}350\u{00A0}000.5")
    }

    // MARK: - Подсказки и предпросмотр

    @Test func validationHintNamesTheMissingField() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        #expect(viewModel.validationHint == AppString.chooseAccount)

        viewModel.selectedAccount = account
        #expect(viewModel.validationHint == AppString.enterAmount)

        viewModel.amount = "100"
        #expect(viewModel.validationHint == nil)
    }

    @Test func predictedBalanceFollowsTransactionType() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.selectedAccount = account

        #expect(viewModel.predictedBalance == nil)

        viewModel.amount = "250"
        #expect(viewModel.predictedBalance == 750)

        viewModel.type = .income
        #expect(viewModel.predictedBalance == 1250)

        // После сохранения сумма уже учтена в балансе счета — предпросмотр больше не нужен
        #expect(viewModel.save(using: context))
        #expect(viewModel.predictedBalance == nil)
    }

    // MARK: - Несохраненные изменения

    @Test func unsavedChangesAppearOnlyAfterInput() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.applyDefaultAccountIfNeeded(from: [account])

        #expect(viewModel.hasUnsavedChanges == false)

        viewModel.amount = "100"
        #expect(viewModel.hasUnsavedChanges)

        #expect(viewModel.save(using: context))
        #expect(viewModel.hasUnsavedChanges == false)
    }

    @Test func editedTransactionHasNoChangesUntilFieldIsTouched() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let transaction = Transaction(amount: 100, date: .now, type: .expense, account: account)
        context.insert(transaction)

        let viewModel = AddTransactionViewModel(transaction: transaction, accountSelection: AccountSelectionStore())

        #expect(viewModel.hasUnsavedChanges == false)

        viewModel.note = "Такси"
        #expect(viewModel.hasUnsavedChanges)
    }

    // MARK: - Счет по умолчанию

    @Test func defaultAccountIsAppliedWhenNothingSelected() {
        let card = Account(name: "Карта", initialBalance: 100)
        let cash = Account(name: "Наличные", initialBalance: 200, isDefault: true)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.applyDefaultAccountIfNeeded(from: [card, cash])

        #expect(viewModel.selectedAccount === cash)
    }

    @Test func defaultAccountDoesNotOverrideExistingSelection() {
        let card = Account(name: "Карта", initialBalance: 100)
        let cash = Account(name: "Наличные", initialBalance: 200, isDefault: true)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.selectedAccount = card
        viewModel.applyDefaultAccountIfNeeded(from: [card, cash])

        #expect(viewModel.selectedAccount === card)
    }

    // MARK: - Тип операции

    @Test func categoryOfAnotherTypeIsClearedAfterTypeChange() {
        let category = Category(name: "Кафе", icon: "cup.and.saucer", colorHex: "#FF9500", type: .expense)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.selectedCategory = category

        viewModel.resetCategoryIfTypeMismatched()
        #expect(viewModel.selectedCategory === category)

        viewModel.type = .income
        viewModel.resetCategoryIfTypeMismatched()
        #expect(viewModel.selectedCategory == nil)
    }

    @Test func saveButtonTitleDependsOnMode() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let creating = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        #expect(creating.saveButtonTitle == AppString.save)

        let transaction = Transaction(amount: 100, date: .now, type: .expense, account: account)
        context.insert(transaction)

        let editing = AddTransactionViewModel(transaction: transaction, accountSelection: AccountSelectionStore())
        #expect(editing.saveButtonTitle == AppString.saveChanges)
    }
}

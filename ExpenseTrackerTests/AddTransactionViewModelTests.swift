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
        let container = try AppModelContainer.make(inMemory: true)

        return ModelContext(container)
    }

    private func transactions(in context: ModelContext) throws -> [Transaction] {
        try context.fetch(FetchDescriptor<Transaction>())
    }

    /// Набирает сумму на клавиатуре калькулятора: «250», «1200+800»
    private func type(_ keys: String, into viewModel: AddTransactionViewModel) {
        for key in keys.compactMap(CalculatorKey.init) {
            viewModel.input(key)
        }
    }

    // MARK: - Tests

    @Test func createsSingleTransaction() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.selectedAccount = account
        type("250", into: viewModel)

        #expect(viewModel.save(using: Repositories(context: context).transactions))

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
        type("250", into: viewModel)

        #expect(viewModel.save(using: Repositories(context: context).transactions))
        #expect(viewModel.save(using: Repositories(context: context).transactions) == false)
        #expect(viewModel.save(using: Repositories(context: context).transactions) == false)

        #expect(try transactions(in: context).count == 1)
        #expect(account.currentBalance == 750)
    }

    @Test func enterIsDisabledAfterSave() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.selectedAccount = account
        type("250", into: viewModel)

        #expect(viewModel.isSaveEnabled)

        #expect(viewModel.save(using: Repositories(context: context).transactions))

        #expect(viewModel.isSaved)
        #expect(viewModel.isSaveEnabled == false)
    }

    @Test func editingUpdatesTransactionWithoutCreatingNewOne() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let transaction = Transaction(amount: 100, date: .now, type: .expense, account: account)
        context.insert(transaction)

        let viewModel = AddTransactionViewModel(transaction: transaction, accountSelection: AccountSelectionStore())
        // Сохраненная сумма уже набрана: сначала стираем ее
        type("⌫⌫⌫400", into: viewModel)

        #expect(viewModel.save(using: Repositories(context: context).transactions))

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
        type("100", into: viewModel)

        #expect(viewModel.save(using: Repositories(context: context).transactions))
        #expect(accountSelection.selectedAccount === cash)
    }

    @Test func savingKeepsAllAccountsMode() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let accountSelection = AccountSelectionStore()

        let viewModel = AddTransactionViewModel(accountSelection: accountSelection)
        viewModel.selectedAccount = account
        type("100", into: viewModel)

        #expect(viewModel.save(using: Repositories(context: context).transactions))
        #expect(accountSelection.selectedAccount == nil)
    }

    @Test func saveFailsWithZeroAmount() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.selectedAccount = account
        type("0", into: viewModel)

        #expect(viewModel.isSaveEnabled == false)
        #expect(viewModel.save(using: Repositories(context: context).transactions) == false)
        #expect(try transactions(in: context).isEmpty)
    }

    @Test func saveFailsWithoutValidAmount() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.selectedAccount = account
        type("", into: viewModel)

        #expect(viewModel.save(using: Repositories(context: context).transactions) == false)
        #expect(viewModel.isSaved == false)
        #expect(try transactions(in: context).isEmpty)
    }

    // MARK: - Сумма и выражение

    @Test func zeroIsPlaceholder() {
        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())

        #expect(viewModel.amountText == "0")
        #expect(viewModel.isAmountPlaceholder)
        #expect(viewModel.expressionText == nil)
    }

    @Test func typedNumberIsShownAsAmount() {
        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        type("12,", into: viewModel)

        #expect(viewModel.amountText == "12,")
        #expect(!viewModel.isAmountPlaceholder)
        #expect(viewModel.expressionText == nil)
    }

    @Test func expressionShowsAboveResult() {
        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        type("1200+800", into: viewModel)

        #expect(viewModel.expressionText == "1\u{00A0}200 + 800")
        #expect(viewModel.amountText == "2\u{00A0}000")
    }

    @Test func divisionByZeroShowsDashAndError() {
        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        type("100÷0", into: viewModel)

        #expect(viewModel.amountText == "—")
        #expect(viewModel.errorMessage == AppString.calculatorDivisionByZero)
        #expect(viewModel.saveButtonState == .checkAmount)
    }

    @Test func editingStartsFromSavedAmount() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)
        let transaction = Transaction(amount: 4850, date: .now, type: .expense, account: account)
        context.insert(transaction)

        let viewModel = AddTransactionViewModel(transaction: transaction, accountSelection: AccountSelectionStore())

        #expect(viewModel.amountText == "4\u{00A0}850")
    }

    // MARK: - Кнопка сохранения

    @Test func saveButtonFollowsInput() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        #expect(viewModel.saveButtonState == .enterAmount)

        type("1200", into: viewModel)
        #expect(viewModel.saveButtonState == .chooseAccount)

        viewModel.selectedAccount = account
        #expect(viewModel.saveButtonState == .save(AppString.saveExpense))

        viewModel.type = .income
        #expect(viewModel.saveButtonState == .save(AppString.saveIncome))

        type("+800", into: viewModel)
        #expect(viewModel.saveButtonState == .saveResult("2\u{00A0}000\u{00A0}₸"))
        #expect(viewModel.saveButtonState.showsEqualsSign)
        #expect(viewModel.saveButtonState.title == "Сохранить 2\u{00A0}000\u{00A0}₸")
    }

    @Test func nonPositiveResultCannotBeSaved() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.selectedAccount = account
        type("100−150", into: viewModel)

        #expect(viewModel.saveButtonState == .checkAmount)
        #expect(viewModel.save(using: Repositories(context: context).transactions) == false)
    }

    @Test func expressionResultIsSaved() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.selectedAccount = account
        type("2×150+50", into: viewModel)

        #expect(viewModel.save(using: Repositories(context: context).transactions))
        #expect(try transactions(in: context).first?.amount == 350)
    }

    // MARK: - Траты категорий за месяц

    @Test func monthlySpendingCountsOnlyCurrentMonthOfCategoryType() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        let food = ExpenseTracker.Category(name: "Еда", icon: "basket", colorHex: "#34C759")
        context.insert(account)
        context.insert(food)

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Almaty") ?? .current
        let now = calendar.date(from: DateComponents(year: 2026, month: 11, day: 25, hour: 12)) ?? .now
        let lastMonth = calendar.date(from: DateComponents(year: 2026, month: 10, day: 30, hour: 12)) ?? .now

        context.insert(Transaction(amount: 1000, date: now, type: .expense, category: food, account: account))
        context.insert(Transaction(amount: 500, date: now, type: .expense, category: food, account: account))
        context.insert(Transaction(amount: 9000, date: lastMonth, type: .expense, category: food, account: account))
        try context.save()

        let spending = AddTransactionViewModel.monthlySpending(of: [food], calendar: calendar, now: now)

        #expect(spending[food.id] == 1500)
    }

    // MARK: - Несохраненные изменения

    @Test func unsavedChangesAppearOnlyAfterInput() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.applyDefaultAccountIfNeeded(from: [account])

        #expect(viewModel.hasUnsavedChanges == false)

        type("100", into: viewModel)
        #expect(viewModel.hasUnsavedChanges)

        #expect(viewModel.save(using: Repositories(context: context).transactions))
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
        type("100", into: creating)
        creating.selectedAccount = account
        #expect(creating.saveButtonState == .save(AppString.saveExpense))

        let transaction = Transaction(amount: 100, date: .now, type: .expense, account: account)
        context.insert(transaction)

        let editing = AddTransactionViewModel(transaction: transaction, accountSelection: AccountSelectionStore())
        #expect(editing.saveButtonState == .save(AppString.saveChanges))
    }

    // MARK: - Дублирование

    @Test func duplicatePrefillsTemplateWithTodayDate() throws {
        let context = try makeContext()
        let account = Account(name: "Kaspi Gold", initialBalance: 10_000)
        let category = ExpenseTracker.Category(name: "Еда", icon: "cup.and.saucer", colorHex: "#8EE3A1")
        context.insert(account)
        context.insert(category)
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
        let original = Transaction(amount: 4_850, date: lastWeek, note: "Продукты на неделю", type: .expense, category: category, account: account)
        context.insert(original)

        let viewModel = AddTransactionViewModel(template: original, accountSelection: AccountSelectionStore())

        #expect(!viewModel.isEditing)
        #expect(viewModel.amountText == "4\u{00A0}850")
        #expect(viewModel.selectedCategory === category)
        #expect(viewModel.selectedAccount === account)
        #expect(viewModel.note == "Продукты на неделю")
        #expect(viewModel.type == .expense)
        #expect(Calendar.current.isDateInToday(viewModel.date))
        // Нетронутую копию можно закрыть без подтверждения
        #expect(!viewModel.hasUnsavedChanges)
    }

    @Test func savingDuplicateCreatesNewTransactionAndKeepsOriginal() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1_000)
        context.insert(account)
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
        let original = Transaction(amount: 300, date: lastWeek, note: "Такси", type: .expense, account: account)
        context.insert(original)

        let viewModel = AddTransactionViewModel(template: original, accountSelection: AccountSelectionStore())
        #expect(viewModel.save(using: Repositories(context: context).transactions))

        let saved = try transactions(in: context)
        #expect(saved.count == 2)
        #expect(original.date == lastWeek)
        let copy = try #require(saved.first { $0 !== original })
        #expect(copy.amount == 300)
        #expect(copy.note == "Такси")
        #expect(copy.account === account)
        #expect(Calendar.current.isDateInToday(copy.date))
        #expect(account.currentBalance == 400)
    }
}

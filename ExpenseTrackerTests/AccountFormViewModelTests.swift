//
//  AccountFormViewModelTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 02.09.2026.
//

import Foundation
import SwiftData
import Testing
@testable import ExpenseTracker

@MainActor
struct AccountFormViewModelTests {

    // MARK: - Helpers

    private func makeContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: Transaction.self, Category.self, Account.self, BudgetPlan.self,
            // Имя у конфигурации своё: безымянное in-memory хранилище общее
            // для всех контейнеров процесса, и параллельные тесты видят чужие данные
            configurations: ModelConfiguration(UUID().uuidString, isStoredInMemoryOnly: true)
        )

        return ModelContext(container)
    }

    private func accounts(in context: ModelContext) throws -> [Account] {
        try context.fetch(FetchDescriptor<Account>())
    }

    // MARK: - Validation

    @Test func nameOfSpacesIsNotValid() {
        let viewModel = AccountFormViewModel()
        viewModel.name = "   "

        #expect(!viewModel.isValid)
        #expect(viewModel.saveButtonTitle == AppString.enterName)
    }

    @Test func savedNameIsTrimmed() throws {
        let context = try makeContext()
        let viewModel = AccountFormViewModel()
        viewModel.name = "  Kaspi Gold  "

        viewModel.save(accounts: [], using: context)

        #expect(try accounts(in: context).first?.name == "Kaspi Gold")
    }

    @Test func invalidFormDoesNotCreateAccount() throws {
        let context = try makeContext()
        let viewModel = AccountFormViewModel()

        viewModel.save(accounts: [], using: context)

        #expect(try accounts(in: context).isEmpty)
    }

    // MARK: - Balance input

    @Test func balanceInputKeepsDigitsAndSingleSeparator() {
        let viewModel = AccountFormViewModel()
        viewModel.initialBalance = "1a2b3,45,6"
        viewModel.sanitizeBalanceInput()

        #expect(viewModel.initialBalance == "123,456")
    }

    @Test func balanceInputKeepsLeadingMinus() {
        let viewModel = AccountFormViewModel()
        viewModel.initialBalance = "-15 000"
        viewModel.sanitizeBalanceInput()

        #expect(viewModel.initialBalance == "-15000")
    }

    @Test func commaBalanceIsSavedAsDecimal() throws {
        let context = try makeContext()
        let viewModel = AccountFormViewModel()
        viewModel.name = "Наличные"
        viewModel.initialBalance = "1500,50"

        viewModel.save(accounts: [], using: context)

        #expect(try accounts(in: context).first?.initialBalance == Decimal(string: "1500.5"))
    }

    // MARK: - Default account

    @Test func firstAccountBecomesDefault() throws {
        let context = try makeContext()
        let viewModel = AccountFormViewModel()
        viewModel.name = "Основной"

        viewModel.save(accounts: [], using: context)

        #expect(try accounts(in: context).first?.isDefault == true)
    }

    @Test func newDefaultAccountResetsPreviousOne() throws {
        let context = try makeContext()
        let existing = Account(name: "Основной", isDefault: true)
        context.insert(existing)

        let viewModel = AccountFormViewModel()
        viewModel.name = "Kaspi Gold"
        viewModel.isDefault = true

        viewModel.save(accounts: [existing], using: context)

        let saved = try accounts(in: context)
        #expect(saved.filter(\.isDefault).count == 1)
        #expect(existing.isDefault == false)
    }

    // MARK: - Unsaved changes

    @Test func untouchedFormHasNoUnsavedChanges() {
        let viewModel = AccountFormViewModel()

        #expect(!viewModel.hasUnsavedChanges)
    }

    @Test func editedFieldMarksFormAsChanged() {
        let account = Account(name: "Kaspi Gold", initialBalance: 1000)
        let viewModel = AccountFormViewModel(account: account)

        #expect(!viewModel.hasUnsavedChanges)

        viewModel.name = "Kaspi Red"

        #expect(viewModel.hasUnsavedChanges)
        #expect(viewModel.saveButtonTitle == AppString.saveChanges)
    }

    @Test func editingUpdatesAccountInsteadOfCreatingNew() throws {
        let context = try makeContext()
        let account = Account(name: "Kaspi Gold", initialBalance: 1000)
        context.insert(account)

        let viewModel = AccountFormViewModel(account: account)
        viewModel.name = "Kaspi Red"
        viewModel.initialBalance = "2000"

        viewModel.save(accounts: [account], using: context)

        let saved = try accounts(in: context)
        #expect(saved.count == 1)
        #expect(saved.first?.name == "Kaspi Red")
        #expect(saved.first?.initialBalance == 2000)
    }
}

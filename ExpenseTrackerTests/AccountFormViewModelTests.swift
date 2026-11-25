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
        let container = try AppModelContainer.make(inMemory: true)

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
        #expect(viewModel.saveButtonTitle == AppString.createAccount)
    }

    @Test func savedNameIsTrimmed() throws {
        let context = try makeContext()
        let viewModel = AccountFormViewModel()
        viewModel.name = "  Kaspi Gold  "

        #expect(viewModel.save(using: Repositories(context: context).accounts))

        #expect(try accounts(in: context).first?.name == "Kaspi Gold")
    }

    @Test func invalidFormDoesNotCreateAccount() throws {
        let context = try makeContext()
        let viewModel = AccountFormViewModel()

        #expect(viewModel.save(using: Repositories(context: context).accounts) == false)

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

        #expect(viewModel.initialBalance == "−15\u{00A0}000")
    }

    @Test func commaBalanceIsSavedAsDecimal() throws {
        let context = try makeContext()
        let viewModel = AccountFormViewModel()
        viewModel.name = "Наличные"
        viewModel.initialBalance = "1500,50"

        #expect(viewModel.save(using: Repositories(context: context).accounts))

        #expect(try accounts(in: context).first?.initialBalance == Decimal(string: "1500.5"))
    }

    // MARK: - Default account

    @Test func firstAccountBecomesDefault() throws {
        let context = try makeContext()
        let viewModel = AccountFormViewModel()
        viewModel.name = "Основной"

        #expect(viewModel.save(using: Repositories(context: context).accounts))

        #expect(try accounts(in: context).first?.isDefault == true)
    }

    @Test func newDefaultAccountResetsPreviousOne() throws {
        let context = try makeContext()
        let existing = Account(name: "Основной", isDefault: true)
        context.insert(existing)

        let viewModel = AccountFormViewModel()
        viewModel.name = "Kaspi Gold"
        viewModel.isDefault = true

        #expect(viewModel.save(using: Repositories(context: context).accounts))

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
        #expect(viewModel.saveButtonTitle == AppString.save)
    }

    @Test func editingUpdatesAccountInsteadOfCreatingNew() throws {
        let context = try makeContext()
        let account = Account(name: "Kaspi Gold", initialBalance: 1000)
        context.insert(account)

        let viewModel = AccountFormViewModel(account: account)
        viewModel.name = "Kaspi Red"
        viewModel.initialBalance = "2000"

        #expect(viewModel.save(using: Repositories(context: context).accounts))

        let saved = try accounts(in: context)
        #expect(saved.count == 1)
        #expect(saved.first?.name == "Kaspi Red")
        #expect(saved.first?.initialBalance == 2000)
    }
    // MARK: - Redesigned form

    @Test func newFormMatchesDefaultPreview() {
        let viewModel = AccountFormViewModel()
        #expect(viewModel.selectedKind == .card)
        #expect(viewModel.selectedColor == "yellow")
        #expect(viewModel.previewBalance == 0)
        #expect(viewModel.isDefault)
        #expect(!viewModel.hasUnsavedChanges)
    }

    @Test func moneyInputGroupsDigitsAndPreservesFractionBeingTyped() {
        let viewModel = AccountFormViewModel()
        viewModel.balanceInput = "1234,"
        #expect(viewModel.balanceInput == "1\u{00A0}234,")
        viewModel.balanceInput = "1 234,50"
        #expect(viewModel.balanceInput == "1\u{00A0}234,50")
        #expect(viewModel.previewBalance == Decimal(string: "1234.5"))
        viewModel.balanceInput = "−0,50"
        #expect(viewModel.balanceInput == "−0,50")
        #expect(viewModel.previewBalance == Decimal(string: "-0.5"))
    }

    @Test func changingKindUpdatesIconAndPersistsIt() throws {
        let context = try makeContext()
        let viewModel = AccountFormViewModel()
        viewModel.name = "Вклад"
        viewModel.selectedKind = .deposit
        viewModel.selectedColor = "teal"
        viewModel.balanceInput = "1 000,50"
        #expect(viewModel.selectedIcon == AccountKind.deposit.icon)
        #expect(viewModel.save(using: Repositories(context: context).accounts))
        let account = try #require(try accounts(in: context).first)
        #expect(account.icon == AccountKind.deposit.icon)
        #expect(account.color == "teal")
        #expect(account.initialBalance == Decimal(string: "1000.5"))
    }

    @Test func legacyIconAndColorArePreservedWhenEditingName() throws {
        let context = try makeContext()
        let account = Account(name: "Старый", icon: "banknote.fill", color: "mint")
        context.insert(account)
        let viewModel = AccountFormViewModel(account: account)
        #expect(viewModel.selectedKind == .cash)
        viewModel.selectedKind = .cash
        viewModel.name = "Новый"
        #expect(viewModel.save(using: Repositories(context: context).accounts))
        #expect(account.icon == "banknote.fill")
        #expect(account.color == "mint")
    }

    @Test func previewBalanceUsesInitialBalanceRatherThanTransactionTotal() throws {
        let context = try makeContext()
        let account = Account(name: "Карта", initialBalance: 32_000)
        context.insert(account)
        context.insert(Transaction(amount: 1_000, date: .now, type: .expense, account: account))
        try context.save()
        let viewModel = AccountFormViewModel(account: account)
        #expect(viewModel.previewBalance == 32_000)
        viewModel.balanceInput = "45 000"
        #expect(viewModel.previewBalance == 45_000)
        #expect(account.currentBalance == 31_000)
    }

}

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

        let viewModel = AddTransactionViewModel()
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

        let viewModel = AddTransactionViewModel()
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

        let viewModel = AddTransactionViewModel()
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

        let viewModel = AddTransactionViewModel()
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

        let viewModel = AddTransactionViewModel(transaction: transaction)
        viewModel.amount = "400"

        #expect(viewModel.save(using: context))

        let saved = try transactions(in: context)
        #expect(saved.count == 1)
        #expect(saved.first?.amount == 400)
        #expect(account.currentBalance == 600)
    }

    @Test func saveFailsWithoutValidAmount() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let viewModel = AddTransactionViewModel()
        viewModel.selectedAccount = account
        viewModel.amount = ""

        #expect(viewModel.save(using: context) == false)
        #expect(viewModel.isSaved == false)
        #expect(try transactions(in: context).isEmpty)
    }
}

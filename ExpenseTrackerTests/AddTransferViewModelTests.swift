//
//  AddTransferViewModelTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 26.11.2026.
//

import Foundation
import SwiftData
import Testing
@testable import ExpenseTracker

@MainActor
struct AddTransferViewModelTests {

    // MARK: - Properties

    private let context: ModelContext
    private let repository: SwiftDataTransactionRepository
    private let kaspi = Account(name: "Kaspi Gold", initialBalance: 78_300)
    private let cash = Account(name: "Наличные", initialBalance: 12_000)

    // MARK: - Init

    init() throws {
        context = ModelContext(try AppModelContainer.make(inMemory: true))
        repository = SwiftDataTransactionRepository(context: context)
        context.insert(kaspi)
        context.insert(cash)
    }

    // MARK: - Helpers

    private func type(_ keys: String, into viewModel: AddTransactionViewModel) {
        for key in keys.compactMap(CalculatorKey.init) {
            viewModel.input(key)
        }
    }

    private func makeTransfer(_ keys: String = "50000") -> AddTransactionViewModel {
        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.kind = .transfer
        viewModel.selectedAccount = kaspi
        type(keys, into: viewModel)
        return viewModel
    }

    // MARK: - Tests

    @Test func saveButtonGoesFromAmountToTargetAccountToTransfer() {
        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.kind = .transfer
        viewModel.selectedAccount = kaspi
        #expect(viewModel.saveButtonState == .enterAmount)

        type("50000", into: viewModel)
        #expect(viewModel.saveButtonState == .chooseTargetAccount)

        viewModel.selectAccount(cash, for: .to)
        #expect(viewModel.saveButtonState == .transfer(MoneyFormat.money(50_000)))
        #expect(viewModel.saveButtonState.showsTransferSign)
        #expect(viewModel.saveButtonState.title == AppString.transferAmount(MoneyFormat.money(50_000)))
    }

    @Test func savesTransferWithoutCategory() throws {
        let viewModel = makeTransfer()
        viewModel.selectAccount(cash, for: .to)

        #expect(viewModel.save(using: repository))

        let saved = try #require(try context.fetch(FetchDescriptor<Transaction>()).first)
        #expect(saved.kind == .transfer)
        #expect(saved.category == nil)
        #expect(saved.fromAccount === kaspi)
        #expect(saved.toAccount === cash)
        #expect(kaspi.currentBalance == 28_300)
        #expect(cash.currentBalance == 62_000)
    }

    @Test func previewShowsBalancesBeforeAndAfter() throws {
        let viewModel = makeTransfer()
        viewModel.selectAccount(cash, for: .to)

        #expect(viewModel.fromBalance == .init(current: 78_300, after: 28_300))
        #expect(viewModel.toBalance == .init(current: 12_000, after: 62_000))
        #expect(!viewModel.isOverdrawn)
        #expect(viewModel.overdraftWarning == nil)
    }

    @Test func overdraftWarnsButDoesNotBlockSaving() throws {
        let viewModel = makeTransfer()
        viewModel.selectAccount(cash, for: .to)
        viewModel.swapTransferAccounts()

        #expect(viewModel.selectedAccount === cash)
        #expect(viewModel.toAccount === kaspi)
        #expect(viewModel.fromBalance?.after == -38_000)
        #expect(viewModel.isOverdrawn)
        #expect(viewModel.overdraftWarning == AppString.transferOverdraftWarning(account: "Наличные", balance: MoneyFormat.money(12_000)))
        #expect(viewModel.isSaveEnabled)
        #expect(viewModel.save(using: repository))
        #expect(cash.currentBalance == -38_000)
    }

    @Test func choosingSameAccountOnOtherSideClearsIt() {
        let viewModel = makeTransfer()
        viewModel.selectAccount(cash, for: .to)

        viewModel.selectAccount(cash, for: .from)
        #expect(viewModel.selectedAccount === cash)
        #expect(viewModel.toAccount == nil)
        #expect(viewModel.counterpartAccount(for: .to) === cash)
    }

    @Test func editingTransferExcludesItFromBalancesAndSavesChanges() throws {
        let transfer = try repository.add(TransactionDraft(amount: 50_000, date: .now, fromAccount: kaspi, toAccount: cash))
        let viewModel = AddTransactionViewModel(transaction: transfer, accountSelection: AccountSelectionStore())

        #expect(viewModel.isTransfer)
        #expect(viewModel.selectedAccount === kaspi)
        #expect(viewModel.toAccount === cash)
        #expect(!viewModel.hasUnsavedChanges)
        #expect(viewModel.saveButtonState == .save(AppString.saveChanges))
        // Как на `EditTransfer.png`: 78 300 → 28 300, а не 28 300 → −21 700
        #expect(viewModel.fromBalance == .init(current: 78_300, after: 28_300))

        viewModel.swapTransferAccounts()
        #expect(viewModel.hasUnsavedChanges)
        #expect(viewModel.save(using: repository))
        #expect(transfer.fromAccount === cash)
        #expect(try context.fetchCount(FetchDescriptor<Transaction>()) == 1)
    }

    @Test func switchingToExpenseSavesRegularTransaction() throws {
        let viewModel = makeTransfer("500")
        viewModel.selectAccount(cash, for: .to)
        viewModel.kind = .expense

        #expect(viewModel.saveButtonState == .save(AppString.saveExpense))
        #expect(viewModel.save(using: repository))

        let saved = try #require(try context.fetch(FetchDescriptor<Transaction>()).first)
        #expect(saved.kind == .expense)
        #expect(saved.account === kaspi)
        #expect(saved.toAccount == nil)
    }

    @Test func duplicatedTransferKeepsAccounts() throws {
        let transfer = try repository.add(TransactionDraft(amount: 1_000, date: .now, fromAccount: kaspi, toAccount: cash))
        let viewModel = AddTransactionViewModel(template: transfer, accountSelection: AccountSelectionStore())

        #expect(viewModel.isTransfer)
        #expect(viewModel.selectedAccount === kaspi)
        #expect(viewModel.toAccount === cash)
        #expect(viewModel.saveButtonState == .transfer(MoneyFormat.money(1_000)))
    }

    // MARK: - Лента

    @Test func feedRowShowsTransferUnsignedForAllAccountsAndSignedForOne() throws {
        let transfer = try repository.add(TransactionDraft(amount: 50_000, date: .now, fromAccount: kaspi, toAccount: cash))

        let all = TransactionRowModel(transfer)
        #expect(all.title == AppString.transfer)
        #expect(all.subtitle == "Kaspi Gold → Наличные")
        #expect(all.amount == "50\u{00A0}000")
        #expect(all.tone == .transfer)

        #expect(TransactionRowModel(transfer, account: kaspi).amount == "−50\u{00A0}000")
        #expect(TransactionRowModel(transfer, account: cash).amount == "+50\u{00A0}000")
    }

    @Test func deletionMessageNamesRoute() throws {
        let transfer = try repository.add(TransactionDraft(amount: 50_000, date: .now, fromAccount: kaspi, toAccount: cash))

        #expect(TransactionDeletionMessage.text(for: transfer)
            == AppString.deleteTransferMessage(title: "Kaspi Gold → Наличные", amount: MoneyFormat.money(50_000)))
    }
}

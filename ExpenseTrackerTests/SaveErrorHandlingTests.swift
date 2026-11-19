//
//  SaveErrorHandlingTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 26.10.2026.
//

import Foundation
import SwiftData
import Testing
@testable import ExpenseTracker

/// Экраны не должны делать вид, что всё сохранилось, когда запись на диск не удалась
@MainActor
struct SaveErrorHandlingTests {

    // MARK: - Helpers

    private struct SaveFailure: Error {}

    /// Репозиторий, у которого любая запись падает — как при ошибке диска
    private struct FailingTransactionRepository: TransactionRepository {
        func add(_ draft: TransactionDraft) throws -> Transaction { throw SaveFailure() }
        func update(_ transaction: Transaction, with draft: TransactionDraft) throws { throw SaveFailure() }
        func delete(_ transaction: Transaction) throws { throw SaveFailure() }
    }

    private struct FailingAccountRepository: AccountRepository {
        func add(_ draft: AccountDraft) throws -> Account { throw SaveFailure() }
        func update(_ account: Account, with draft: AccountDraft) throws { throw SaveFailure() }
        func delete(_ account: Account) throws { throw SaveFailure() }
    }

    private func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            accountSelection: AccountSelectionStore(),
            periodStore: DashboardPeriodStore(defaults: UserDefaults(suiteName: UUID().uuidString) ?? .standard),
            limitStore: MonthlyLimitStore(defaults: UserDefaults(suiteName: UUID().uuidString) ?? .standard)
        )
    }

    // MARK: - Tests

    @Test func failedTransactionSaveKeepsFormOpenAndShowsError() {
        let viewModel = AddTransactionViewModel(accountSelection: AccountSelectionStore())
        viewModel.selectedAccount = Account(name: "Основной")
        viewModel.amount = "250"

        #expect(viewModel.save(using: FailingTransactionRepository()) == false)
        #expect(viewModel.showingSaveError)
        // Форма не помечена сохраненной: повторное нажатие снова попробует записать
        #expect(viewModel.isSaved == false)
    }

    @Test func failedDeleteDoesNotOfferUndo() throws {
        let viewModel = makeDashboardViewModel()
        let transaction = Transaction(amount: 100, date: .now, type: .expense)

        viewModel.deleteTransaction(transaction, using: FailingTransactionRepository())

        #expect(viewModel.undoAction == nil)
        #expect(viewModel.showingSaveError)
    }

    @Test func failedAccountSaveKeepsFormOpenAndShowsError() {
        let viewModel = AccountFormViewModel()
        viewModel.name = "Kaspi Gold"

        #expect(viewModel.save(using: FailingAccountRepository()) == false)
        #expect(viewModel.showingSaveError)
    }
}

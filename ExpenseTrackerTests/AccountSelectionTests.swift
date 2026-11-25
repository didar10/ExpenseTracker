import Foundation
import SwiftData
import Testing
@testable import ExpenseTracker

@MainActor
struct AccountSelectionTests {
    private struct SaveFailure: Error {}
    private struct FailingRepository: AccountRepository {
        func add(_ draft: AccountDraft) throws -> Account { throw SaveFailure() }
        func update(_ account: Account, with draft: AccountDraft) throws { throw SaveFailure() }
        func delete(_ account: Account) throws { throw SaveFailure() }
        func reorder(_ accounts: [Account]) throws { throw SaveFailure() }
    }

    private func draft(_ name: String) -> AccountDraft {
        AccountDraft(name: name, icon: "wallet.bifold", color: "yellow", initialBalance: 0, isDefault: false)
    }

    private func ordered(in context: ModelContext) throws -> [Account] {
        try context.fetch(FetchDescriptor<Account>(sortBy: [SortDescriptor(\.sortOrder), SortDescriptor(\.createdAt)]))
    }

    @Test func reorderPersistsAcrossContextsAndNewAccountsAppend() throws {
        let container = try AppModelContainer.make(inMemory: true)
        let context = ModelContext(container)
        let repository = SwiftDataAccountRepository(context: context)
        let a = try repository.add(draft("Карта"))
        let b = try repository.add(draft("Наличные"))
        let c = try repository.add(draft("Накопления"))
        let viewModel = AccountSelectionViewModel()
        viewModel.isEditing = true
        viewModel.move(c.persistentModelID, to: a.persistentModelID, in: [a, b, c], using: repository)
        _ = try repository.add(draft("Новый"))

        let freshContext = ModelContext(container)
        #expect(try ordered(in: freshContext).map(\.name) == ["Накопления", "Карта", "Наличные", "Новый"])
        #expect(try ordered(in: freshContext).filter(\.isDefault).count == 1)
    }

    @Test func reorderDownwardsUsesFinalDestination() throws {
        let context = ModelContext(try AppModelContainer.make(inMemory: true))
        let repository = SwiftDataAccountRepository(context: context)
        let a = try repository.add(draft("А"))
        let b = try repository.add(draft("Б"))
        let c = try repository.add(draft("В"))
        let viewModel = AccountSelectionViewModel()
        viewModel.isEditing = true
        viewModel.move(a.persistentModelID, to: c.persistentModelID, in: [a, b, c], using: repository)
        #expect(try ordered(in: context).map(\.name) == ["Б", "В", "А"])
    }

    @Test func cannotReorderOutsideEditMode() throws {
        let context = ModelContext(try AppModelContainer.make(inMemory: true))
        let repository = SwiftDataAccountRepository(context: context)
        let a = try repository.add(draft("А"))
        let b = try repository.add(draft("Б"))
        let viewModel = AccountSelectionViewModel()
        viewModel.move(a.persistentModelID, to: b.persistentModelID, in: [a, b], using: FailingRepository())
        #expect(!viewModel.showingSaveError)
        #expect(try ordered(in: context).map(\.name) == ["А", "Б"])
    }

    @Test func failedReorderKeepsOrderAndShowsError() throws {
        let context = ModelContext(try AppModelContainer.make(inMemory: true))
        let repository = SwiftDataAccountRepository(context: context)
        let a = try repository.add(draft("А"))
        let b = try repository.add(draft("Б"))
        let viewModel = AccountSelectionViewModel()
        viewModel.isEditing = true
        viewModel.move(a.persistentModelID, to: b.persistentModelID, in: [a, b], using: FailingRepository())
        #expect(viewModel.showingSaveError)
        #expect(try ordered(in: context).map(\.name) == ["А", "Б"])
    }

    @Test func cancelledDeletionDoesNotDeleteAnything() throws {
        let context = ModelContext(try AppModelContainer.make(inMemory: true))
        let repository = SwiftDataAccountRepository(context: context)
        let account = try repository.add(draft("Наличные"))
        let viewModel = AccountSelectionViewModel()
        viewModel.requestDeletion(of: account)
        #expect(viewModel.deletionTitle == AppString.deleteNamedAccount("Наличные"))
        viewModel.cancelDeletion()
        viewModel.confirmDeletion(using: repository)
        #expect(try ordered(in: context).count == 1)
    }

    @Test func deletingSelectedAccountRemovesItsTransactionsAndClearsSelection() throws {
        let context = ModelContext(try AppModelContainer.make(inMemory: true))
        let repository = SwiftDataAccountRepository(context: context)
        let account = try repository.add(draft("Наличные"))
        let other = try repository.add(draft("Карта"))
        context.insert(Transaction(amount: 500, date: .now, type: .expense, account: account))
        context.insert(Transaction(amount: 700, date: .now, type: .income, account: other))
        try context.save()
        let selection = AccountSelectionStore()
        selection.selectedAccount = account
        let viewModel = AccountSelectionViewModel()
        viewModel.requestDeletion(of: account)
        viewModel.confirmDeletion(using: repository)
        let remaining = try ordered(in: context)
        selection.removeSelectionIfDeleted(from: remaining)

        #expect(remaining.map(\.name) == ["Карта"])
        #expect(try context.fetch(FetchDescriptor<Transaction>()).map(\.amount) == [700])
        #expect(selection.selectedAccount == nil)
        #expect(viewModel.accountToDelete == nil)
        #expect(!viewModel.showingSaveError)
    }

    @Test func failedDeletionKeepsAccountAndShowsError() {
        let account = Account(name: "Наличные")
        let viewModel = AccountSelectionViewModel()
        viewModel.requestDeletion(of: account)
        viewModel.confirmDeletion(using: FailingRepository())
        #expect(viewModel.showingSaveError)
        #expect(!account.isDeleted)
        #expect(viewModel.accountToDelete == nil)
    }
}

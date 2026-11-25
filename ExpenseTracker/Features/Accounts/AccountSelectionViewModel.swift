import SwiftData
import SwiftUI

/// Состояние выбора и редактирования. Все записи проходят через репозиторий.
@MainActor
@Observable
final class AccountSelectionViewModel {
    var isEditing = false
    var showingDeleteConfirmation = false
    var showingSaveError = false
    private(set) var accountToDelete: Account?
    private(set) var deletionTitle = ""

    func requestDeletion(of account: Account) {
        deletionTitle = AppString.deleteNamedAccount(account.name)
        accountToDelete = account
        showingDeleteConfirmation = true
    }

    func cancelDeletion() {
        showingDeleteConfirmation = false
        accountToDelete = nil
    }

    func confirmDeletion(using repository: AccountRepository) {
        guard let account = accountToDelete else { return }
        showingDeleteConfirmation = false
        accountToDelete = nil
        do {
            try repository.delete(account)
        } catch {
            showingSaveError = true
        }
    }

    func move(
        _ source: PersistentIdentifier,
        to target: PersistentIdentifier,
        in accounts: [Account],
        using repository: AccountRepository
    ) {
        guard isEditing,
              let from = accounts.firstIndex(where: { $0.persistentModelID == source }),
              let to = accounts.firstIndex(where: { $0.persistentModelID == target }),
              from != to else { return }
        var reordered = accounts
        let account = reordered.remove(at: from)
        reordered.insert(account, at: to)
        do {
            try repository.reorder(reordered)
        } catch {
            showingSaveError = true
        }
    }
}

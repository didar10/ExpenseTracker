import SwiftData
import SwiftUI
import Testing
@testable import ExpenseTracker

/// Содержимое листа на SE и обычном iPhone: обе темы, длинный бейдж при правке и пустое состояние.
@MainActor
@Suite(.serialized)
struct AccountSelectionSnapshotTests {
    private func environment(empty: Bool = false) throws -> FixtureEnvironment {
        let environment = FixtureEnvironment(.empty)
        if !empty {
            let specs: [(String, String, String, Decimal)] = [
                ("Основная карта", "wallet.bifold", "yellow", 493_050),
                ("Наличные", "banknote", "green", 32_000),
                ("Накопления", "building.columns", "purple", 450_000)
            ]
            for (index, spec) in specs.enumerated() {
                let account = Account(name: spec.0, icon: spec.1, color: spec.2, initialBalance: spec.3, isDefault: index == 0)
                account.sortOrder = index
                environment.context.insert(account)
            }
            try environment.context.save()
        }
        return environment
    }

    @Test func selection() throws {
        assertScreenSnapshots(of: AccountSelectionSheet().fixture(try environment()))
    }

    @Test func editing() throws {
        let viewModel = AccountSelectionViewModel()
        viewModel.isEditing = true
        assertScreenSnapshots(of: AccountSelectionSheet(viewModel: viewModel).fixture(try environment()))
    }

    @Test func empty() throws {
        assertScreenSnapshots(of: AccountSelectionSheet().fixture(try environment(empty: true)))
    }

    @Test func deletion() throws {
        let viewModel = AccountSelectionViewModel()
        viewModel.isEditing = true
        assertScreenSnapshots(of:
            AccountSelectionSheet(viewModel: viewModel).fixture(try environment())
                .overlay {
                    ZStack {
                        DS.Color.scrim.ignoresSafeArea()
                        BrutalAlertCard(
                            title: AppString.deleteNamedAccount("Наличные"),
                            message: AppString.deleteAccountMessage,
                            confirmTitle: AppString.delete,
                            onConfirm: {}, onCancel: {}
                        )
                    }
                }
        )
    }
}

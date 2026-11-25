import SwiftData
import SwiftUI
import Testing
@testable import ExpenseTracker

@MainActor
@Suite(.serialized)
struct AccountFormSnapshotTests {
    @Test func create() {
        assertScreenSnapshots(of: AccountFormView().fixture(FixtureEnvironment(.empty)))
    }

    @Test func edit() throws {
        let environment = FixtureEnvironment(.empty)
        let account = Account(name: "Наличные", icon: AccountKind.cash.icon, color: "green", initialBalance: 32_000)
        environment.context.insert(account)
        try environment.context.save()
        assertScreenSnapshots(of: AccountFormView(account: account).fixture(environment))
    }

    @Test func blackAccount() {
        let viewModel = AccountFormViewModel()
        viewModel.name = "Накопления"
        viewModel.selectedKind = .deposit
        viewModel.selectedColor = "black"
        viewModel.balanceInput = "1 234 567,50"
        assertScreenSnapshots(of: AccountFormView(viewModel: viewModel).fixture(FixtureEnvironment(.empty)))
    }
}

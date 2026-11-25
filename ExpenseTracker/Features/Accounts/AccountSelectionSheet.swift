import SwiftData
import SwiftUI

/// Общий лист выбора на главной и в статистике; в настройках — управление счетами.
struct AccountSelectionSheet: View {
    var selectedAccount: Account?
    var onSelect: (Account?) -> Void = { _ in }
    var managesAccounts = false

    @Query(sort: [SortDescriptor(\Account.sortOrder), SortDescriptor(\Account.createdAt)])
    private var accounts: [Account]

    @State private var viewModel: AccountSelectionViewModel
    @State private var showingAddAccount = false
    @State private var editingAccount: Account?
    @State private var contentHeight = DS.AccountList.initialSheetHeight
    @State private var headerHeight = DS.Size.control

    @Environment(\.repositories) private var repositories
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        selectedAccount: Account? = nil,
        onSelect: @escaping (Account?) -> Void = { _ in },
        managesAccounts: Bool = false,
        viewModel: AccountSelectionViewModel? = nil
    ) {
        self.selectedAccount = selectedAccount
        self.onSelect = onSelect
        self.managesAccounts = managesAccounts
        _viewModel = State(initialValue: viewModel ?? AccountSelectionViewModel())
    }

    private var availableAccounts: [Account] { accounts.filter(\.isAvailable) }

    private var items: [AccountListItem] {
        let available = availableAccounts
        let all = AccountListItem(totalBalance: available.reduce(0) { $0 + $1.currentBalance })
        return (managesAccounts ? [] : [all]) + available.map(AccountListItem.init)
    }

    var body: some View {
        VStack(spacing: .zero) {
            SheetGrabber()
            header
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { headerHeight = $0 }
                .padding(.bottom, DS.AccountList.headerBottom)

            ScrollView {
                VStack(spacing: DS.Spacing.md) {
                    if availableAccounts.isEmpty {
                        EmptyAccountsView { showingAddAccount = true }
                    } else {
                        AccountList(
                            items: items,
                            selectedID: availableAccounts.first(where: { $0 === selectedAccount })?.persistentModelID,
                            isEditing: viewModel.isEditing,
                            showsSelection: !managesAccounts,
                            onSelect: select,
                            onDelete: requestDeletion,
                            onMove: move
                        )
                        newAccountButton
                    }
                }
                .padding(.bottom, DS.Spacing.sm)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { contentHeight = $0 }
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
        }
        .padding(.top, SheetGrabber.topPadding)
        .padding(.horizontal, DS.Spacing.xl)
        .background(DS.Color.bg)
        .brutalSheetPresentation(detents: [.height(sheetHeight), .large])
        .onChange(of: accounts.isEmpty) { _, empty in
            if empty { viewModel.isEditing = false }
        }
        .sheet(isPresented: $showingAddAccount) { AccountFormView() }
        .sheet(item: $editingAccount) { AccountFormView(account: $0) }
        .brutalAlert(
            isPresented: $viewModel.showingDeleteConfirmation,
            title: viewModel.deletionTitle,
            message: AppString.deleteAccountMessage,
            confirmTitle: AppString.delete,
            onConfirm: { viewModel.confirmDeletion(using: repositories.accounts) },
            onCancel: viewModel.cancelDeletion
        )
        .saveErrorAlert(isPresented: $viewModel.showingSaveError)
    }

    private var sheetHeight: CGFloat {
        max(DS.AccountList.minimumSheetHeight,
            SheetGrabber.topPadding + SheetGrabber.height + DS.AccountList.headerBottom + headerHeight + contentHeight)
    }

    private var header: some View {
        HStack(spacing: DS.Spacing.md) {
            Text(managesAccounts || accounts.isEmpty ? AppString.accounts : AppString.selectAccount)
                .font(DS.Font.sheetTitle)
                .foregroundStyle(DS.Color.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            if !accounts.isEmpty {
                Button {
                    withAnimation(reduceMotion ? nil : DS.Motion.toggle) { viewModel.isEditing.toggle() }
                } label: {
                    Text(viewModel.isEditing ? AppString.done : AppString.edit)
                        .font(DS.Font.control)
                        .padding(.horizontal, DS.Spacing.md)
                        .frame(minHeight: DS.AccountList.headerButtonHeight)
                }
                .buttonStyle(.outlineClick)
            }
        }
    }

    private var newAccountButton: some View {
        Button { showingAddAccount = true } label: {
            HStack(spacing: DS.Spacing.sm) {
                DS.Icon.plus
                Text(AppString.newAccount)
            }
            .font(DS.Font.buttonSmall)
            .foregroundStyle(DS.Color.ink)
            .frame(maxWidth: .infinity, minHeight: DS.Size.menuRow)
            .contentShape(RoundedRectangle(cornerRadius: DS.Radius.control))
            .overlay {
                RoundedRectangle(cornerRadius: DS.Radius.control)
                    .strokeBorder(DS.Color.ink, style: StrokeStyle(lineWidth: DS.Stroke.regular, dash: DS.Stroke.dash))
            }
        }
        .buttonStyle(.outlineClickSegment)
        .accessibilityIdentifier(AccessibilityID.accountSelectionAdd)
    }

    private func select(_ id: PersistentIdentifier?) {
        let account = availableAccounts.first(where: { $0.persistentModelID == id })
        if viewModel.isEditing || managesAccounts {
            editingAccount = account
        } else {
            onSelect(account)
            dismiss()
        }
    }

    private func requestDeletion(_ id: PersistentIdentifier) {
        guard let account = availableAccounts.first(where: { $0.persistentModelID == id }) else { return }
        viewModel.requestDeletion(of: account)
    }

    private func move(_ source: PersistentIdentifier, to target: PersistentIdentifier) {
        withAnimation(reduceMotion ? nil : DS.Motion.toggle) {
            viewModel.move(source, to: target, in: availableAccounts, using: repositories.accounts)
        }
    }
}

#if DEBUG
private struct AccountSelectionPreview: View {
    var fixture: Fixture = .sample
    var isEditing = false
    var showsDelete = false
    var showsError = false
    var body: some View {
        let environment = FixtureEnvironment(fixture)
        let viewModel = AccountSelectionViewModel()
        viewModel.isEditing = isEditing
        viewModel.showingSaveError = showsError
        if showsDelete, let account = try? environment.context.fetch(FetchDescriptor<Account>()).first {
            viewModel.requestDeletion(of: account)
        }
        return AccountSelectionSheet(viewModel: viewModel).fixture(environment)
    }
}
#Preview("Данные · светлая") { AccountSelectionPreview() }
#Preview("Данные · темная") { AccountSelectionPreview().preferredColorScheme(.dark) }
#Preview("Пусто · светлая") { AccountSelectionPreview(fixture: .empty) }
#Preview("Пусто · темная") { AccountSelectionPreview(fixture: .empty).preferredColorScheme(.dark) }
#Preview("Редактирование · светлая") { AccountSelectionPreview(isEditing: true) }
#Preview("Редактирование · темная") { AccountSelectionPreview(isEditing: true).preferredColorScheme(.dark) }
#Preview("Удаление · светлая") { AccountSelectionPreview(isEditing: true, showsDelete: true) }
#Preview("Удаление · темная") { AccountSelectionPreview(isEditing: true, showsDelete: true).preferredColorScheme(.dark) }
#Preview("Ошибка · светлая") { AccountSelectionPreview(showsError: true) }
#Preview("Ошибка · темная") { AccountSelectionPreview(showsError: true).preferredColorScheme(.dark) }
#endif

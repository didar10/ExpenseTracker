//
//  AddTransactionView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftData
import SwiftUI

/// Экран «Новая операция» и его режим редактирования: сумма калькулятором,
/// счет и дата пилюлями, заметка, лента категорий. В режиме «Перевод» вместо пилюли счета
/// и ленты — карточка «Откуда / Куда». Лист во всю высоту, без темной обводки
struct AddTransactionView: View {

    // MARK: - Properties

    @Environment(\.repositories) private var repositories
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @StateObject private var viewModel: AddTransactionViewModel

    @FocusState private var isNoteFocused: Bool

    @State private var accountSheet: AccountSheet?
    @State private var showingDateSheet = false
    @State private var categorySheet: CategoryListSheetMode?
    @State private var showingDiscardAlert = false
    @State private var showingDeleteAlert = false
    /// Удаление выполняется после закрытия листа: экран не должен читать удаленную модель
    @State private var isDeletionConfirmed = false
    /// Лист ниже `Metrics.compactHeight` (iPhone SE): сумма мельче, зазоры меньше
    @State private var isCompact = false

    @Query(sort: \Category.name)
    private var categories: [Category]

    @Query(sort: \Account.createdAt, order: .forward)
    private var accounts: [Account]

    /// Удаление операции в режиме редактирования; nil — кнопки удаления нет
    private let onDelete: ((Transaction) -> Void)?

    // MARK: - Init

    init(
        transaction: Transaction? = nil,
        template: Transaction? = nil,
        accountSelection: AccountSelectionStore,
        onDelete: ((Transaction) -> Void)? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: AddTransactionViewModel(
                transaction: transaction,
                template: template,
                accountSelection: accountSelection
            )
        )
        self.onDelete = onDelete
    }

    // MARK: - Computed Properties

    /// Категории текущего типа в порядке названий — для листа «Категории»
    private var typeCategories: [CarouselCategory] {
        let matching = categories.filter { $0.type == viewModel.type }
        let spending = AddTransactionViewModel.monthlySpending(of: matching)
        return CategoryCarouselItems.make(from: matching, spending: spending)
    }

    private var categorySelection: Binding<UUID?> {
        Binding {
            viewModel.selectedCategory?.id
        } set: { id in
            viewModel.selectedCategory = id.flatMap { id in categories.first { $0.id == id } }
        }
    }

    private var canDelete: Bool {
        viewModel.isEditing && onDelete != nil
    }

    private var kindOptions: [SegmentedSwitch<TransactionKind>.Option] {
        [
            .init(value: .expense, title: AppString.expense),
            .init(value: .income, title: AppString.income),
            .init(value: .transfer, title: AppString.transfer)
        ]
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            header

            AmountHeaderView(
                expression: viewModel.expressionText,
                amount: viewModel.amountText,
                isPlaceholder: viewModel.isAmountPlaceholder,
                errorMessage: viewModel.errorMessage,
                isCompact: isCompact,
                keystrokes: viewModel.keystrokes
            )

            metaPills
                .padding(.top, DS.Spacing.sm)

            NoteField(text: $viewModel.note, isFocused: $isNoteFocused)
                .padding(.top, Metrics.noteTop)

            if viewModel.isTransfer {
                transferSection
                    .padding(.top, DS.Spacing.md)
            } else {
                carousel
                    .padding(.top, DS.Spacing.md)
                    .padding(.horizontal, -DS.Spacing.xl)
            }

            Spacer(minLength: isCompact ? .zero : DS.Spacing.sm)

            CalculatorKeypad { key in
                isNoteFocused = false
                viewModel.input(key)
            }
            // Клавиши забирают место раньше пустого промежутка над ними
            .layoutPriority(1)

            saveButton
                .padding(.top, Metrics.saveTop)
        }
        .padding(.horizontal, DS.Spacing.xl)
        .padding(.top, Metrics.topPadding)
        .padding(.bottom, DS.Spacing.sm)
        .background(DS.Color.bg)
        .onGeometryChange(for: Bool.self) { $0.size.height < Metrics.compactHeight } action: { isCompact = $0 }
        // Клавиатура заметки перекрывает калькулятор, а не сдвигает экран
        .ignoresSafeArea(.keyboard)
        .presentationDetents([.large])
        .presentationBackground(DS.Color.bg)
        .presentationCornerRadius(DS.Radius.sheet)
        .presentationDragIndicator(.hidden)
        // Введенные данные не теряются молча: закрытие проходит через подтверждение
        .interactiveDismissDisabled(viewModel.hasUnsavedChanges)
        .sensoryFeedback(.error, trigger: viewModel.errorMessage) { _, message in message != nil }
        .sensoryFeedback(.success, trigger: viewModel.isSaved) { _, isSaved in isSaved }
        .onChange(of: viewModel.kind) {
            viewModel.resetCategoryIfTypeMismatched()
        }
        .sensoryFeedback(.warning, trigger: viewModel.isOverdrawn) { _, isOverdrawn in isOverdrawn }
        .task(id: accounts.count) {
            viewModel.applyDefaultAccountIfNeeded(from: accounts)
        }
        .onDisappear(perform: deleteIfConfirmed)
        .brutalSheet(item: $accountSheet, title: \.title) { sheet in
            accountPicker(sheet)
        }
        .brutalSheet(isPresented: $showingDateSheet, title: AppString.date, actionTitle: AppString.cancel, detents: [.large]) {
            DatePickerSheetContent(date: viewModel.date) { date in
                viewModel.date = date
                showingDateSheet = false
            }
        }
        .brutalSheet(item: $categorySheet, title: { _ in AppString.categories }, detents: [.large]) { mode in
            CategoryListSheetContent(
                categories: typeCategories,
                selection: viewModel.selectedCategory?.id,
                focusesSearch: mode == .search
            ) { id in
                categorySelection.wrappedValue = id
                categorySheet = nil
            }
        }
        .brutalAlert(
            isPresented: $showingDiscardAlert,
            title: AppString.discardChangesTitle,
            message: AppString.discardChangesMessage,
            confirmTitle: AppString.discardChanges
        ) {
            dismiss()
        }
        .brutalAlert(
            isPresented: $showingDeleteAlert,
            title: AppString.deleteTransactionTitle,
            message: deleteMessage,
            confirmTitle: AppString.delete
        ) {
            isDeletionConfirmed = true
            dismiss()
        }
        .saveErrorAlert(isPresented: $viewModel.showingSaveError)
    }
}

// MARK: - Subviews

private extension AddTransactionView {

    var header: some View {
        HStack(spacing: Metrics.headerSpacing) {
            IconButton(icon: DS.Icon.close, accessibilityLabel: AppString.accessibilityClose, action: handleClose)

            SegmentedSwitch(selection: $viewModel.kind, options: kindOptions, labelSize: .compact)
                .accessibilityLabel(AppString.transactionType)

            if canDelete {
                deleteButton
            } else {
                Color.clear
                    .frame(width: DS.Size.control, height: DS.Size.control)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(viewModel.screenTitle)
    }

    var deleteButton: some View {
        Button {
            isNoteFocused = false
            showingDeleteAlert = true
        } label: {
            DS.Icon.trash
                .font(.system(size: DS.Size.iconL, weight: .semibold))
                .frame(height: DS.Size.control)
        }
        .buttonStyle(PressIntoShadowStyle(variant: .danger))
        .frame(width: DS.Size.control)
        .accessibilityLabel(AppString.deleteTransactionLabel)
    }

    var metaPills: some View {
        let rules = TransactionDateRules()

        return HStack(spacing: DS.Spacing.sm) {
            // В переводе счета — в карточке «Откуда / Куда», под суммой остается только дата
            if !viewModel.isTransfer {
                accountPill
            }

            MetaPill(
                leading: .icon(DS.Icon.calendar),
                title: rules.pillTitle(for: viewModel.date),
                value: rules.timeText(for: viewModel.date),
                accessibilityHint: AppString.selectDate
            ) {
                isNoteFocused = false
                showingDateSheet = true
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(Metrics.pillMinimumScale)
    }

    @ViewBuilder
    var accountPill: some View {
        if let account = viewModel.availableFromAccount {
            MetaPill(
                leading: .badge(Image(systemName: account.icon), DS.accountColor(named: account.color)),
                title: account.name,
                value: MoneyFormat.money(account.currentBalance),
                accessibilityHint: AppString.dsChooseAccountHint
            ) {
                openAccountSheet(.entry)
            }
        } else {
            MetaPill(
                leading: .icon(AppImage.creditcard),
                title: AppString.chooseAccount,
                value: "",
                accessibilityHint: AppString.dsChooseAccountHint
            ) {
                openAccountSheet(.entry)
            }
        }
    }

    /// Карточка «Откуда / Куда» и под ней подсказка или предупреждение о минусе
    var transferSection: some View {
        VStack(spacing: DS.Spacing.sm) {
            TransferAccountsCard(
                from: transferRow(viewModel.availableFromAccount, balance: viewModel.fromBalance),
                to: transferRow(viewModel.availableToAccount, balance: viewModel.toBalance),
                isOverdrawn: viewModel.isOverdrawn,
                onSelectFrom: { openAccountSheet(.transfer(.from)) },
                onSelectTo: { openAccountSheet(.transfer(.to)) },
                onSwap: swapAccounts
            )

            if let warning = viewModel.overdraftWarning {
                overdraftWarning(warning)
            } else {
                Text(AppString.transferHint)
                    .font(DS.Font.caption)
                    .foregroundStyle(DS.Color.ink2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
        .animation(reduceMotion ? nil : DS.Motion.toggle, value: viewModel.isOverdrawn)
    }

    func overdraftWarning(_ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: DS.Spacing.sm) {
            DS.Icon.warning
                .font(.system(size: DS.Size.iconS, weight: .semibold))
                .accessibilityHidden(true)

            Text(text)
                .font(DS.Font.captionMedium)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(DS.Color.danger)
        .accessibilityElement(children: .combine)
    }

    func transferRow(
        _ account: Account?,
        balance: AddTransactionViewModel.TransferBalance?
    ) -> TransferAccountsCard.Row? {
        guard let account, let balance else { return nil }

        return TransferAccountsCard.Row(
            name: account.name,
            icon: Image(systemName: account.icon),
            color: DS.accountColor(named: account.color),
            balance: MoneyFormat.money(balance.current),
            balanceAfter: balance.after.map(MoneyFormat.money),
            isNegativeAfter: balance.isNegativeAfter
        )
    }

    @ViewBuilder
    func accountPicker(_ sheet: AccountSheet) -> some View {
        switch sheet {
        case .entry:
            AccountPickerSheetContent(selectedAccount: viewModel.selectedAccount) { account in
                viewModel.selectAccount(account)
                accountSheet = nil
            }
        case .transfer(let side):
            AccountPickerSheetContent(
                selectedAccount: side == .from ? viewModel.availableFromAccount : viewModel.availableToAccount,
                disabledAccount: viewModel.counterpartAccount(for: side),
                disabledTag: side == .from ? AppString.transferCreditTag : AppString.transferDebitTag
            ) { account in
                viewModel.selectAccount(account, for: side)
                accountSheet = nil
            }
        }
    }

    var carousel: some View {
        CategoryCarousel(
            categories: CarouselCategory.orderedBySpend(typeCategories),
            selection: categorySelection,
            onSearch: { openCategorySheet(.search) },
            onAllCategories: { openCategorySheet(.browse) }
        )
        // Смена «Расход/Доход» — другой набор категорий: лента собирается заново
        .id(viewModel.type)
    }

    var saveButton: some View {
        let state = viewModel.saveButtonState

        return PrimaryButton(
            title: state.title,
            icon: saveButtonIcon(for: state),
            action: handleSave
        )
        .disabled(!state.isEnabled)
    }

    func saveButtonIcon(for state: AddTransactionViewModel.SaveButtonState) -> Image? {
        if state.showsEqualsSign { return DS.Icon.equal }
        if state.showsTransferSign { return DS.Icon.transfer }
        return nil
    }

    var deleteMessage: String? {
        viewModel.editingTransaction.map(TransactionDeletionMessage.text(for:))
    }
}

// MARK: - Actions

private extension AddTransactionView {

    func handleSave() {
        isNoteFocused = false
        guard viewModel.save(using: repositories.transactions) else { return }

        dismiss()
    }

    func handleClose() {
        isNoteFocused = false

        guard viewModel.hasUnsavedChanges else {
            dismiss()
            return
        }

        showingDiscardAlert = true
    }

    func openAccountSheet(_ sheet: AccountSheet) {
        isNoteFocused = false
        accountSheet = sheet
    }

    func swapAccounts() {
        isNoteFocused = false
        withAnimation(reduceMotion ? nil : DS.Motion.toggle) {
            viewModel.swapTransferAccounts()
        }
    }

    func openCategorySheet(_ mode: CategoryListSheetMode) {
        isNoteFocused = false
        categorySheet = mode
    }

    func deleteIfConfirmed() {
        guard isDeletionConfirmed, let transaction = viewModel.editingTransaction else { return }

        isDeletionConfirmed = false
        onDelete?(transaction)
    }
}

// MARK: - Account Sheet

/// Какой счет выбирается на листе: счет расхода/дохода или сторона перевода
private enum AccountSheet: Identifiable, Hashable {
    case entry
    case transfer(AddTransactionViewModel.TransferSide)

    var id: Self { self }

    var title: String {
        switch self {
        case .entry: return AppString.accountSheetTitle
        case .transfer(.from): return AppString.transferFrom
        case .transfer(.to): return AppString.transferTo
        }
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/AddTransaction.html` (.sheet, .seg, .note, .cta)
    static let topPadding: CGFloat = 10
    static let headerSpacing: CGFloat = 10
    static let noteTop: CGFloat = 10
    static let saveTop: CGFloat = 10
    static let pillMinimumScale: CGFloat = 0.8
    /// Ниже этой высоты листа экран целиком не помещается в обычных размерах
    static let compactHeight: CGFloat = 700
}

// MARK: - Previews

#if DEBUG
private struct AddTransactionPreview: View {

    let fixture: Fixture
    /// Открыть на редактирование первую операцию этого вида
    var editedKind: TransactionKind?

    var body: some View {
        let environment = FixtureEnvironment(fixture)
        let transaction = editedKind.flatMap { kind in
            (try? environment.context.fetch(FetchDescriptor<Transaction>()))?.first { $0.kind == kind }
        }

        Color.clear
            .sheet(isPresented: .constant(true)) {
                AddTransactionView(transaction: transaction, accountSelection: AccountSelectionStore()) { _ in }
            }
            .fixture(environment)
    }
}

#Preview("Новый расход · светлая") {
    AddTransactionPreview(fixture: .sample)
}

#Preview("Новый расход · темная") {
    AddTransactionPreview(fixture: .sample)
        .preferredColorScheme(.dark)
}

#Preview("Редактирование · светлая") {
    AddTransactionPreview(fixture: .sample, editedKind: .expense)
}

#Preview("Редактирование · темная") {
    AddTransactionPreview(fixture: .sample, editedKind: .expense)
        .preferredColorScheme(.dark)
}

#Preview("Редактирование перевода · светлая") {
    AddTransactionPreview(fixture: .sample, editedKind: .transfer)
}

#Preview("Редактирование перевода · темная") {
    AddTransactionPreview(fixture: .sample, editedKind: .transfer)
        .preferredColorScheme(.dark)
}

#Preview("Пусто: нет счетов и категорий") {
    AddTransactionPreview(fixture: .empty)
}
#endif

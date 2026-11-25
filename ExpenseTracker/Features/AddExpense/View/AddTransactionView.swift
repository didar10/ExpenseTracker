//
//  AddTransactionView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftData
import SwiftUI

/// Экран «Новая операция» и его режим редактирования: сумма калькулятором,
/// счет и дата пилюлями, заметка, лента категорий. Лист во всю высоту, без темной обводки
struct AddTransactionView: View {

    // MARK: - Properties

    @Environment(\.repositories) private var repositories
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @StateObject private var viewModel: AddTransactionViewModel

    @FocusState private var isNoteFocused: Bool

    @State private var showingAccountSheet = false
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

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            header

            AmountHeaderView(
                expression: viewModel.expressionText,
                amount: viewModel.amountText,
                isPlaceholder: viewModel.isAmountPlaceholder,
                errorMessage: viewModel.errorMessage,
                isCompact: isCompact
            )

            metaPills
                .padding(.top, DS.Spacing.sm)

            NoteField(text: $viewModel.note, isFocused: $isNoteFocused)
                .padding(.top, Metrics.noteTop)

            carousel
                .padding(.top, DS.Spacing.md)
                .padding(.horizontal, -DS.Spacing.xl)

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
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.calculator)
        .sensoryFeedback(.error, trigger: viewModel.errorMessage) { _, message in message != nil }
        .sensoryFeedback(.success, trigger: viewModel.isSaved) { _, isSaved in isSaved }
        .onChange(of: viewModel.type) {
            viewModel.resetCategoryIfTypeMismatched()
        }
        .task(id: accounts.count) {
            viewModel.applyDefaultAccountIfNeeded(from: accounts)
        }
        .onDisappear(perform: deleteIfConfirmed)
        .brutalSheet(isPresented: $showingAccountSheet, title: AppString.accountSheetTitle) {
            AccountPickerSheetContent(selectedAccount: viewModel.selectedAccount) { account in
                viewModel.selectedAccount = account
                showingAccountSheet = false
            }
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

            SegmentedSwitch(
                selection: $viewModel.type,
                options: [
                    .init(value: .expense, title: AppString.expense),
                    .init(value: .income, title: AppString.income)
                ]
            )
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
            if let account = viewModel.selectedAccount, account.isAvailable {
                MetaPill(
                    leading: .badge(Image(systemName: account.icon), DS.accountColor(named: account.color)),
                    title: account.name,
                    value: MoneyFormat.money(account.currentBalance),
                    accessibilityHint: AppString.dsChooseAccountHint,
                    action: openAccountSheet
                )
            } else {
                MetaPill(
                    leading: .icon(AppImage.creditcard),
                    title: AppString.chooseAccount,
                    value: "",
                    accessibilityHint: AppString.dsChooseAccountHint,
                    action: openAccountSheet
                )
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
            icon: state.showsEqualsSign ? DS.Icon.equal : nil,
            action: handleSave
        )
        .disabled(!state.isEnabled)
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

    func openAccountSheet() {
        isNoteFocused = false
        showingAccountSheet = true
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
    var editsFirstTransaction = false

    var body: some View {
        let environment = FixtureEnvironment(fixture)
        let transaction = editsFirstTransaction
            ? (try? environment.context.fetch(FetchDescriptor<Transaction>()))?.first { $0.type == .expense }
            : nil

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
    AddTransactionPreview(fixture: .sample, editsFirstTransaction: true)
}

#Preview("Редактирование · темная") {
    AddTransactionPreview(fixture: .sample, editsFirstTransaction: true)
        .preferredColorScheme(.dark)
}

#Preview("Пусто: нет счетов и категорий") {
    AddTransactionPreview(fixture: .empty)
}
#endif

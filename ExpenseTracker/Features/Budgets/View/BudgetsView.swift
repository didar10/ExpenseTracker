//
//  BudgetsView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftData
import SwiftUI

/// Бюджеты: заголовок с «+», выбор месяца, карточка «Лимит на месяц» и бюджеты категорий.
/// Без лимита и бюджетов — пустое состояние с шагами «Как это работает»
struct BudgetsView: View {

    // MARK: - Properties

    @State private var viewModel: BudgetsViewModel
    @State private var isMonthMenuShown = false

    @Query(sort: \BudgetPlan.createdAt, order: .reverse)
    private var budgetPlans: [BudgetPlan]

    @Query(sort: \Category.name)
    private var categories: [Category]

    @Query(sort: \Transaction.date, order: .reverse)
    private var transactions: [Transaction]

    @Environment(\.repositories) private var repositories
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Init

    init(limitStore: MonthlyLimitStore) {
        _viewModel = State(initialValue: BudgetsViewModel(limitStore: limitStore))
    }

    init(viewModel: BudgetsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            header
                .padding(.horizontal, DS.Spacing.xl)

            ScrollView {
                VStack(alignment: .leading, spacing: .zero) {
                    monthSelector

                    if viewModel.isEmpty {
                        BudgetsEmptyState(onSetLimit: viewModel.editMonthlyLimit, onAddBudget: viewModel.addBudget)
                            .padding(.top, Metrics.emptyTop)
                    } else {
                        content
                    }
                }
                .padding(.top, Metrics.selectorTop)
                .padding(.horizontal, DS.Spacing.xl)
                .padding(.bottom, DS.Spacing.lg)
                .animation(reduceMotion ? nil : DS.Motion.toggle, value: viewModel.items)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(DS.Color.bg)
        .sensoryFeedback(.selection, trigger: viewModel.monthOffset)
        .onAppear(perform: syncData)
        .onChange(of: budgetPlans) { _, _ in syncData() }
        .onChange(of: transactions) { _, _ in syncData() }
        .brutalCustomSheet(isPresented: $viewModel.showingAddBudget) {
            AddBudgetView(viewModel: AddBudgetViewModel(
                categories: categories,
                budgetPlans: budgetPlans,
                transactions: transactions,
                limit: viewModel.limitStore.limit
            ))
        }
        .monthlyLimitSheet(isPresented: $viewModel.showingMonthlyLimit, limitStore: viewModel.limitStore)
        .brutalAlert(
            isPresented: $viewModel.showingDeleteConfirmation,
            title: AppString.deleteBudgetConfirm,
            message: AppString.cannotUndo,
            confirmTitle: AppString.delete,
            onConfirm: { viewModel.confirmDelete(using: repositories.budgets) },
            onCancel: viewModel.cancelDelete
        )
        .saveErrorAlert(isPresented: $viewModel.showingSaveError)
    }
}

// MARK: - Actions

private extension BudgetsView {

    func syncData() {
        viewModel.updateData(budgetPlans: budgetPlans, transactions: transactions)
    }
}

// MARK: - Subviews

private extension BudgetsView {

    var header: some View {
        HStack {
            Text(AppString.budgets)
                .font(DS.Font.screenTitle)
                .foregroundStyle(DS.Color.ink)
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: DS.Spacing.sm)

            IconButton(icon: DS.Icon.plus, accessibilityLabel: AppString.newBudget, elevation: .raised, action: viewModel.addBudget)
        }
        .frame(minHeight: Metrics.titleHeight)
        .padding(.top, DS.Spacing.xs)
    }

    var monthSelector: some View {
        PeriodSelector(
            title: viewModel.monthTitle,
            layout: .fullWidth,
            isNextEnabled: viewModel.canGoToNextMonth,
            onPrevious: viewModel.goToPreviousMonth,
            onNext: viewModel.goToNextMonth
        ) {
            isMonthMenuShown = true
        }
        .brutalMenu(
            isPresented: $isMonthMenuShown,
            items: monthMenuItems,
            minWidth: BrutalMenuMetrics.periodMinWidth
        )
        .accessibilityHint(AppString.budgetsChooseMonthHint)
    }

    var monthMenuItems: [BrutalMenuItem] {
        viewModel.monthOptions.map { option in
            BrutalMenuItem(title: option.title, isSelected: option.offset == viewModel.monthOffset) {
                viewModel.selectMonth(offset: option.offset)
            }
        }
    }

    @ViewBuilder
    var content: some View {
        if let overview = viewModel.limitOverview {
            MonthlyLimitCard(overview: overview, onEditLimit: viewModel.editMonthlyLimit)
                .padding(.top, DS.Spacing.lg)
        } else {
            DashedActionRow(
                icon: AppImage.limitTarget,
                title: AppString.budgetsLimitPromptTitle,
                subtitle: AppString.budgetsLimitPromptHint,
                action: viewModel.editMonthlyLimit
            )
            .padding(.top, DS.Spacing.lg)
        }

        sectionHeader

        if !viewModel.items.isEmpty {
            budgetsList
        }

        DashedActionRow(
            title: AppString.budgetsAddCategoryBudget,
            subtitle: unallocatedSubtitle,
            action: viewModel.addBudget
        )
        .padding(.top, viewModel.items.isEmpty ? .zero : Metrics.addRowTop)
    }

    var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(AppString.budgetsCategories)
                .dsLabel()
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: DS.Spacing.sm)

            Text(allocatedTitle)
                .font(DS.Font.moneySmall)
                .foregroundStyle(DS.Color.ink2)
                .lineLimit(1)
                .minimumScaleFactor(Metrics.minimumScale)
        }
        .padding(.horizontal, Metrics.sectionInset)
        .padding(.top, Metrics.sectionTop)
        .padding(.bottom, DS.Spacing.sm)
    }

    var budgetsList: some View {
        Card(padding: nil) {
            VStack(spacing: .zero) {
                ForEach(viewModel.items) { item in
                    if item.id != viewModel.items.first?.id {
                        ListDivider()
                    }

                    CategoryBudgetRow(item: item) {
                        viewModel.requestDelete(item)
                    }
                }
            }
        }
    }

    /// «распределено 185 000 из 250 000»; без лимита — только распределенная сумма
    var allocatedTitle: String {
        let allocated = MoneyFormat.number(viewModel.allocated)

        guard let limit = viewModel.limitStore.limit else {
            return AppString.budgetsAllocated(allocated)
        }
        return AppString.budgetsAllocatedOf(allocated, MoneyFormat.number(limit))
    }

    /// «не распределено 65 000 ₸» или превышение распределенного над лимитом
    var unallocatedSubtitle: String? {
        guard let unallocated = viewModel.unallocated else { return nil }

        return unallocated >= 0
            ? AppString.budgetsUnallocated(MoneyFormat.money(unallocated))
            : AppString.budgetsOverAllocated(MoneyFormat.money(-unallocated))
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/Budgets.html` и `BudgetsEmpty.html`
    static let titleHeight: CGFloat = 48
    static let selectorTop: CGFloat = 10
    static let emptyTop: CGFloat = 18
    static let sectionTop: CGFloat = 22
    static let sectionInset: CGFloat = 2
    static let addRowTop: CGFloat = 10
    static let minimumScale: CGFloat = 0.8
}

// MARK: - Previews

#if DEBUG
private struct BudgetsPreview: View {

    let fixture: Fixture
    var hasLimit = true
    var hasSaveError = false

    var body: some View {
        let environment = FixtureEnvironment(fixture)
        if !hasLimit {
            environment.limitStore.setLimit(nil)
        }
        let viewModel = BudgetsViewModel(limitStore: environment.limitStore)
        viewModel.showingSaveError = hasSaveError

        return BudgetsView(viewModel: viewModel)
            .floatingTabBar(
                tabs: TabItem.allCases.map(\.floatingTab),
                selection: .constant(TabItem.plans),
                addAccessibilityLabel: AppString.addTransactionLabel
            ) {}
            .fixture(environment)
    }
}

#Preview("Данные · светлая") {
    BudgetsPreview(fixture: .sample)
}

#Preview("Данные · темная") {
    BudgetsPreview(fixture: .sample)
        .preferredColorScheme(.dark)
}

#Preview("Без лимита · светлая") {
    BudgetsPreview(fixture: .sample, hasLimit: false)
}

#Preview("Без лимита · темная") {
    BudgetsPreview(fixture: .sample, hasLimit: false)
        .preferredColorScheme(.dark)
}

#Preview("Пусто · светлая") {
    BudgetsPreview(fixture: .empty)
}

#Preview("Пусто · темная") {
    BudgetsPreview(fixture: .empty)
        .preferredColorScheme(.dark)
}

#Preview("Ошибка удаления · светлая") {
    BudgetsPreview(fixture: .sample, hasSaveError: true)
}

#Preview("Ошибка удаления · темная") {
    BudgetsPreview(fixture: .sample, hasSaveError: true)
        .preferredColorScheme(.dark)
}
#endif

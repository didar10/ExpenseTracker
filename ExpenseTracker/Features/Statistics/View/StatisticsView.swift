//
//  StatisticsView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftData
import SwiftUI

/// Статистика: заголовок, счет и период, «Расходы / Доходы», пончик по категориям и список
/// с долями. Шапка и переключатель остаются на месте, прокручиваются пончик и список
struct StatisticsView: View {

    // MARK: - Properties

    @Bindable var viewModel: StatisticsViewModel

    @State private var selectedStatistic: CategoryStatistic?
    @State private var showingAccountsView = false

    @Query(sort: \Transaction.date, order: .reverse)
    private var transactionsTrigger: [Transaction]

    @Query(sort: \Account.createdAt, order: .forward)
    private var accountsTrigger: [Account]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            header
                .padding(.horizontal, DS.Spacing.xl)

            ScrollView {
                VStack(spacing: .zero) {
                    CategoryDonutChart(
                        statistics: viewModel.statistics,
                        total: viewModel.totalAmount,
                        title: viewModel.totalTitle
                    )
                    .padding(.top, Metrics.chartTop)

                    if viewModel.isEmpty {
                        emptyState
                    } else {
                        CategoryBreakdownList(
                            statistics: viewModel.statistics,
                            total: viewModel.totalAmount,
                            type: viewModel.selectedType
                        ) { statistic in
                            selectedStatistic = statistic
                        }
                    }
                }
                .padding(.horizontal, DS.Spacing.xl)
                .padding(.bottom, DS.Spacing.lg)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(DS.Color.bg)
        .sensoryFeedback(.impact(weight: .light), trigger: selectedStatistic) { _, statistic in statistic != nil }
        .sensoryFeedback(.selection, trigger: viewModel.selectedType)
        .sheet(item: $selectedStatistic) { statistic in
            CategoryTransactionsView(
                category: statistic.category,
                periodTitle: viewModel.periodTitle,
                transactions: viewModel.transactions(for: statistic.category)
            )
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showingAccountsView) {
            AccountSelectionSheet(selectedAccount: viewModel.selectedAccount) { account in
                withAnimation(reduceMotion ? nil : DS.Motion.toggle) {
                    viewModel.selectedAccount = account
                }
                showingAccountsView = false
            }
        }
        .onChange(of: transactionsTrigger) { _, _ in
            viewModel.fetchData()
        }
        .onChange(of: accountsTrigger) { _, _ in
            viewModel.fetchData()
        }
        .onChange(of: viewModel.selectedAccount) { _, _ in
            viewModel.refreshStatistics()
        }
        .onAppear {
            // Экран пересоздается при каждом переключении вкладки, поэтому
            // перезагружаем данные: пока вкладка неактивна, @Query не отслеживает изменения
            viewModel.setup(with: modelContext)
        }
    }
}

// MARK: - Subviews

private extension StatisticsView {

    var header: some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text(AppString.tabStatistics)
                .font(DS.Font.screenTitle)
                .foregroundStyle(DS.Color.ink)
                .frame(minHeight: Metrics.titleHeight)
                .padding(.top, DS.Spacing.xs)
                .accessibilityAddTraits(.isHeader)

            HStack(spacing: DS.Spacing.sm) {
                AccountPill(
                    title: viewModel.selectedAccount?.name ?? AppString.allAccounts,
                    balance: MoneyFormat.money(accountBalance),
                    icon: viewModel.selectedAccount.map { Image(systemName: $0.icon) } ?? AppImage.allAccounts,
                    fillsWidth: true
                ) {
                    showingAccountsView = true
                }

                PeriodMenuSelector(
                    title: viewModel.periodTitle,
                    selection: viewModel.selectedPeriod,
                    periods: StatisticsPeriod.allCases,
                    isNavigable: viewModel.isPeriodNavigable,
                    canGoForward: viewModel.canGoToNextPeriod,
                    onSelect: viewModel.changePeriod,
                    onPrevious: viewModel.goToPreviousPeriod,
                    onNext: viewModel.goToNextPeriod
                )
            }
            .padding(.top, Metrics.rowSpacing)

            SegmentedSwitch(
                selection: $viewModel.selectedType,
                options: [
                    .init(value: .expense, title: AppString.expenses, icon: AppImage.expenseDirection),
                    .init(value: .income, title: AppString.incomes, icon: AppImage.incomeDirection)
                ]
            )
            .padding(.top, Metrics.rowSpacing)
            .accessibilityLabel(AppString.transactionType)
        }
    }

    var emptyState: some View {
        VStack(spacing: .zero) {
            Text(AppString.noData)
                .font(DS.Font.dialogTitle)
                .foregroundStyle(DS.Color.ink)
                .padding(.top, Metrics.emptyTitleTop)
                .accessibilityAddTraits(.isHeader)

            Text(viewModel.emptyStateHint)
                .font(DS.Font.bodySmall)
                .foregroundStyle(DS.Color.ink2)
                .frame(maxWidth: Metrics.hintWidth)
                .padding(.top, Metrics.hintTop)

            // Данные мог скрыть фильтр периода — предлагаем посмотреть за все время
            if viewModel.isFilteredByPeriod {
                Button {
                    viewModel.resetPeriod()
                } label: {
                    Text(AppString.periodAllTime)
                        .font(DS.Font.control)
                        .padding(.horizontal, DS.Spacing.lg)
                        .frame(minHeight: DS.Size.control)
                }
                .buttonStyle(.outlineClick)
                .padding(.top, DS.Spacing.lg)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }

    /// Баланс в пилюле: выбранного счета или всех счетов
    var accountBalance: Decimal {
        viewModel.selectedAccount?.currentBalance ?? viewModel.totalBalance
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/Statistics.html` и `StatisticsEmpty.html`
    static let titleHeight: CGFloat = 48
    static let rowSpacing: CGFloat = 10
    static let chartTop: CGFloat = 18
    static let emptyTitleTop: CGFloat = 22
    static let hintTop: CGFloat = 6
    static let hintWidth: CGFloat = 260
}

// MARK: - Hashable for Navigation

extension CategoryStatistic: Hashable {
    static func == (lhs: CategoryStatistic, rhs: CategoryStatistic) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Previews

#if DEBUG
private struct StatisticsPreview: View {

    let fixture: Fixture
    var type: TransactionType = .expense

    var body: some View {
        let environment = FixtureEnvironment(fixture)
        let viewModel = StatisticsViewModel(accountSelection: AccountSelectionStore())
        viewModel.selectedType = type

        return StatisticsView(viewModel: viewModel)
            .floatingTabBar(
                tabs: TabItem.allCases.map(\.floatingTab),
                selection: .constant(TabItem.statistics),
                addAccessibilityLabel: AppString.addTransactionLabel
            ) {}
            .fixture(environment)
    }
}

#Preview("Расходы · светлая") {
    StatisticsPreview(fixture: .sample)
}

#Preview("Расходы · темная") {
    StatisticsPreview(fixture: .sample)
        .preferredColorScheme(.dark)
}

#Preview("Доходы · светлая") {
    StatisticsPreview(fixture: .sample, type: .income)
}

#Preview("Доходы · темная") {
    StatisticsPreview(fixture: .sample, type: .income)
        .preferredColorScheme(.dark)
}

#Preview("Пусто · светлая") {
    StatisticsPreview(fixture: .empty)
}

#Preview("Пусто · темная") {
    StatisticsPreview(fixture: .empty)
        .preferredColorScheme(.dark)
}
#endif

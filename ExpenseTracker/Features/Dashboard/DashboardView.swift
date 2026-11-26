//
//  DashboardView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftData
import SwiftUI

/// Главная: счет и период, баланс, доходы и расходы за период, «Можно потратить сегодня»
/// и лента операций по дням. При прокрутке сверху закрепляется компактная шапка
struct DashboardView: View {

    // MARK: - Properties

    @Query(sort: \Transaction.date, order: .reverse)
    private var transactions: [Transaction]

    @Query(sort: \Account.createdAt, order: .forward)
    private var accounts: [Account]

    @Environment(\.repositories) private var repositories
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @StateObject private var viewModel: DashboardViewModel

    /// Баланс уехал под верхний край — показывается компактная шапка
    @State private var isCompactHeaderShown = false

    private let accountSelection: AccountSelectionStore
    /// Тап по «Доходам» или «Расходам» — статистика этого типа
    private let onShowStatistics: (TransactionType) -> Void

    // MARK: - Init

    init(
        accountSelection: AccountSelectionStore,
        periodStore: DashboardPeriodStore,
        limitStore: MonthlyLimitStore,
        onShowStatistics: @escaping (TransactionType) -> Void = { _ in }
    ) {
        self.accountSelection = accountSelection
        self.onShowStatistics = onShowStatistics
        _viewModel = StateObject(
            wrappedValue: DashboardViewModel(
                accountSelection: accountSelection,
                periodStore: periodStore,
                limitStore: limitStore
            )
        )
    }

    // MARK: - Body

    var body: some View {
        @Bindable var deletion = viewModel.transactionDeletion
        // Баланс, карточки и лента считаются из одного снимка данных
        let snapshot = viewModel.makeSnapshot(accounts: accounts, transactions: transactions)

        ScrollView {
            VStack(alignment: .leading, spacing: .zero) {
                topBar(totalBalance: snapshot.totalBalance)

                balance(snapshot)
                    .padding(.top, Metrics.balanceTop)
                    .onGeometryChange(for: Bool.self) { proxy in
                        proxy.frame(in: .scrollView).maxY < .zero
                    } action: { isHidden in
                        isCompactHeaderShown = isHidden
                    }

                if viewModel.showsDailyAllowance {
                    DailyAllowanceCard(allowance: snapshot.dailyAllowance, action: viewModel.showMonthlyLimit)
                        .padding(.top, snapshot.dailyAllowance == nil ? Metrics.promptTop : DS.Spacing.lg)
                        .transition(.opacity)
                }

                feed(snapshot.sections)
            }
            .padding(.horizontal, DS.Spacing.xl)
            .padding(.top, DS.Spacing.xs)
            .padding(.bottom, DS.Spacing.lg)
        }
        .scrollIndicators(.hidden)
        .background(DS.Color.bg)
        .overlay(alignment: .top) {
            if isCompactHeaderShown {
                compactHeader(totalBalance: snapshot.totalBalance)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(reduceMotion ? nil : DS.Motion.overlay, value: isCompactHeaderShown)
        .overlay(alignment: .bottom) { undoToast }
        .onAppear {
            viewModel.syncSelectedAccount(with: accounts)
        }
        .onChange(of: accounts) { _, newAccounts in
            viewModel.syncSelectedAccount(with: newAccounts)
        }
        .sheet(item: $viewModel.selectedTransaction) { transaction in
            AddTransactionView(transaction: transaction, accountSelection: accountSelection) { transaction in
                viewModel.transactionDeletion.deleteTransaction(transaction, using: repositories.transactions)
            }
        }
        .sheet(item: $viewModel.duplicatedTransaction) { template in
            AddTransactionView(template: template, accountSelection: accountSelection)
        }
        .brutalAlert(
            isPresented: $deletion.showingDeleteConfirmation,
            title: AppString.deleteTransactionTitle,
            message: viewModel.transactionDeletion.deletionMessage,
            confirmTitle: AppString.delete,
            onConfirm: { viewModel.transactionDeletion.confirmDeletion(using: repositories.transactions) },
            onCancel: viewModel.transactionDeletion.cancelDeletion
        )
        .sheet(isPresented: $viewModel.showingAccountsView) {
            AccountSelectionSheet(selectedAccount: viewModel.selectedAccount) { account in
                viewModel.selectAccount(account)
            }
        }
        .monthlyLimitSheet(isPresented: $viewModel.showingMonthlyLimit, limitStore: viewModel.limitStore)
        .saveErrorAlert(isPresented: $deletion.showingSaveError)
        .onReceive(
            NotificationCenter.default
                .publisher(for: .NSCalendarDayChanged)
                .receive(on: RunLoop.main)
        ) { _ in
            viewModel.refreshToday()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                viewModel.refreshToday()
            }
        }
    }
}

// MARK: - Subviews

private extension DashboardView {

    func topBar(totalBalance: Decimal) -> some View {
        HStack(spacing: DS.Spacing.sm) {
            AccountPill(
                title: accountTitle,
                balance: MoneyFormat.money(totalBalance),
                icon: accountIcon,
                action: viewModel.showAccounts
            )
            .layoutPriority(1)

            Spacer(minLength: .zero)

            periodControl(allowsArrows: true)
        }
    }

    func balance(_ snapshot: DashboardSnapshot) -> some View {
        DashboardBalanceView(
            title: viewModel.periodFilter.period == .allTime ? AppString.balanceAllTime : AppString.onAccounts,
            balance: snapshot.totalBalance,
            income: snapshot.periodBalance.totalIncome,
            expenses: snapshot.periodBalance.totalExpenses,
            showsFlows: !transactions.isEmpty,
            onIncomeTap: { onShowStatistics(.income) },
            onExpenseTap: { onShowStatistics(.expense) }
        )
    }

    @ViewBuilder
    func feed(_ sections: [TransactionSection]) -> some View {
        if sections.isEmpty {
            // Пусто только в выбранном периоде — предлагаем показать все время
            let canShowAllTime = viewModel.isFilteredByPeriod && !transactions.isEmpty
            DashboardEmptyState(
                // Операций нет совсем — подсказка про первую запись, а не про период
                hint: transactions.isEmpty ? AppString.noTransactionsHint : viewModel.emptyStateHint,
                onShowAllTime: canShowAllTime ? { viewModel.resetPeriod() } : nil
            )
            .padding(.top, Metrics.emptyTop)
        } else {
            LazyVStack(spacing: .zero) {
                ForEach(sections) { section in
                    TransactionDaySection(
                        section: section,
                        account: viewModel.selectedAccount,
                        onTap: { viewModel.handleTransactionTap($0) },
                        onDuplicate: { viewModel.duplicateTransaction($0) },
                        onDelete: { viewModel.transactionDeletion.requestDeletion(of: $0) }
                    )
                }
            }
        }
    }

    func compactHeader(totalBalance: Decimal) -> some View {
        DashboardCompactHeader(
            title: accountTitle + AppString.titleSeparator + viewModel.periodFilter.title,
            balance: totalBalance
        ) {
            periodControl(allowsArrows: false)
        }
    }

    func periodControl(allowsArrows: Bool) -> some View {
        PeriodMenuSelector(
            filter: viewModel.periodFilter,
            allowsArrows: allowsArrows,
            onSelect: viewModel.changePeriod,
            onPrevious: viewModel.goToPreviousPeriod,
            onNext: viewModel.goToNextPeriod
        )
    }

    @ViewBuilder
    var undoToast: some View {
        if let undoAction = viewModel.transactionDeletion.undoAction {
            UndoToast(message: undoAction.message) {
                viewModel.transactionDeletion.undoLastAction(using: repositories.transactions)
            }
            .id(undoAction.id)
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.bottom, DS.Spacing.sm)
            .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
        }
    }

    var accountTitle: String {
        viewModel.selectedAccount?.name ?? AppString.allAccounts
    }

    var accountIcon: Image {
        viewModel.selectedAccount.map { Image(systemName: $0.icon) } ?? AppImage.allAccounts
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/Main.html` и `MainEmpty.html`
    static let balanceTop: CGFloat = 22
    static let promptTop: CGFloat = 18
    static let emptyTop: CGFloat = 56
}

// MARK: - Previews

#if DEBUG
private struct DashboardPreview: View {

    let fixture: Fixture
    var period: StatisticsPeriod = .month

    var body: some View {
        let environment = FixtureEnvironment(fixture)
        let periodStore = DashboardPeriodStore(defaults: environment.defaults)
        periodStore.select(period)

        return TabView {
            DashboardView(
                accountSelection: AccountSelectionStore(),
                periodStore: periodStore,
                limitStore: environment.limitStore
            )
            .toolbar(.hidden, for: .tabBar)
        }
        .floatingTabBar(
            tabs: TabItem.allCases.map(\.floatingTab),
            selection: .constant(TabItem.dashboard),
            addAccessibilityLabel: AppString.addTransactionLabel
        ) {}
        .fixture(environment)
    }
}

#Preview("Данные · светлая") {
    DashboardPreview(fixture: .sample)
}

#Preview("Данные · темная") {
    DashboardPreview(fixture: .sample)
        .preferredColorScheme(.dark)
}

#Preview("Все время · светлая") {
    DashboardPreview(fixture: .sample, period: .allTime)
}

#Preview("Все время · темная") {
    DashboardPreview(fixture: .sample, period: .allTime)
        .preferredColorScheme(.dark)
}

#Preview("Пусто · светлая") {
    DashboardPreview(fixture: .empty)
}

#Preview("Пусто · темная") {
    DashboardPreview(fixture: .empty)
        .preferredColorScheme(.dark)
}
#endif

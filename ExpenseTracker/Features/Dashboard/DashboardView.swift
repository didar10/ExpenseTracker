//
//  DashboardView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI
import SwiftData

struct DashboardView: View {

    // MARK: - Properties

    @Query(sort: \Transaction.date, order: .reverse)
    private var transactions: [Transaction]

    @Query(sort: \Account.createdAt, order: .forward)
    private var accounts: [Account]

    @Environment(\.repositories) private var repositories
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var viewModel: DashboardViewModel

    @State private var isContentScrolled = false

    private let accountSelection: AccountSelectionStore

    // MARK: - Init

    init(
        accountSelection: AccountSelectionStore,
        periodStore: DashboardPeriodStore,
        limitStore: MonthlyLimitStore
    ) {
        self.accountSelection = accountSelection
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
        // Баланс, шапка и секции считаются из одного снимка данных
        let snapshot = viewModel.makeSnapshot(accounts: accounts, transactions: transactions)

        return NavigationStack {
            VStack(spacing: 0) {
                accountPickerHeader(totalBalance: snapshot.totalBalance)

                content(for: snapshot)
            }
            .background(AppColor.background)
            .overlay(alignment: .bottom) { undoToast }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.syncSelectedAccount(with: accounts)
            }
            .onChange(of: accounts) { _, newAccounts in
                viewModel.syncSelectedAccount(with: newAccounts)
            }
            .sheet(item: $viewModel.selectedTransaction) { transaction in
                AddTransactionView(transaction: transaction, accountSelection: accountSelection)
            }
            .sheet(isPresented: $viewModel.showingAccountsView) {
                accountSelectionSheet
            }
            .saveErrorAlert(isPresented: $viewModel.showingSaveError)
            .sheet(isPresented: $viewModel.showingMonthlyLimit) {
                MonthlyLimitView(limitStore: viewModel.limitStore)
            }
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
}

// MARK: - Subviews
private extension DashboardView {

    func accountPickerHeader(totalBalance: Decimal) -> some View {
        HStack(spacing: AppSpacing.medium) {
            AccountPickerButton(
                selectedAccount: viewModel.selectedAccount,
                totalBalance: totalBalance,
                action: viewModel.showAccounts
            )

            Spacer()

            PeriodMenuButton(
                selectedPeriod: viewModel.periodFilter.period,
                onSelect: viewModel.changePeriod
            )
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.small)
        .background(AppColor.background)
        // Список, уехавший под шапку, отделяется линией
        .overlay(alignment: .bottom) {
            Divider()
                .opacity(isContentScrolled ? 1 : 0)
                .animation(.easeOut(duration: 0.15), value: isContentScrolled)
        }
    }

    @ViewBuilder
    func content(for snapshot: DashboardSnapshot) -> some View {
        if #available(iOS 18.0, *) {
            scrollContent(for: snapshot)
                .onScrollGeometryChange(for: Bool.self) { geometry in
                    geometry.contentOffset.y > geometry.contentInsets.top
                } action: { _, isScrolled in
                    isContentScrolled = isScrolled
                }
        } else {
            scrollContent(for: snapshot)
        }
    }

    func scrollContent(for snapshot: DashboardSnapshot) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                BalanceCardView(
                    balanceData: snapshot.periodBalance,
                    periodFilter: viewModel.periodFilter,
                    onPreviousPeriod: viewModel.goToPreviousPeriod,
                    onNextPeriod: viewModel.goToNextPeriod
                )

                if viewModel.showsDailyAllowance {
                    DailyAllowanceCardView(
                        allowance: snapshot.dailyAllowance,
                        onTap: viewModel.showMonthlyLimit
                    )
                    .padding(.horizontal, AppSpacing.large)
                    .padding(.bottom, AppSpacing.large)
                    .transition(.opacity)
                }

                TransactionsListView(
                    sections: snapshot.sections,
                    emptyStateHint: viewModel.emptyStateHint,
                    isFilteredByPeriod: viewModel.isFilteredByPeriod,
                    onTransactionTap: viewModel.handleTransactionTap,
                    onResetPeriod: viewModel.resetPeriod,
                    onRepeat: { viewModel.repeatTransaction($0, using: repositories.transactions) },
                    onDelete: { viewModel.deleteTransaction($0, using: repositories.transactions) }
                )
            }
            .padding(.bottom, AppSpacing.tabBarBottomInset)
        }
        .scrollDismissesKeyboard(.immediately)
    }

    @ViewBuilder
    var undoToast: some View {
        if let undoAction = viewModel.undoAction {
            UndoToastView(message: undoAction.message) {
                viewModel.undoLastAction(using: repositories.transactions)
            }
            .id(undoAction.id)
            .padding(.horizontal, AppSpacing.large)
            .padding(.bottom, AppSpacing.tabBarBottomInset)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    var accountSelectionSheet: some View {
        AccountSelectionSheet(
            selectedAccount: viewModel.selectedAccount,
            onSelect: { account in
                viewModel.selectAccount(account)
            }
        )
    }
}

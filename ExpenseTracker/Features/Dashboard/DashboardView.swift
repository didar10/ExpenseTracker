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

    @StateObject private var viewModel: DashboardViewModel

    private let accountSelection: AccountSelectionStore

    // MARK: - Init

    init(accountSelection: AccountSelectionStore, periodStore: DashboardPeriodStore) {
        self.accountSelection = accountSelection
        _viewModel = StateObject(
            wrappedValue: DashboardViewModel(
                accountSelection: accountSelection,
                periodStore: periodStore
            )
        )
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                accountPickerHeader

                ScrollView {
                    VStack(spacing: .zero) {
                        BalanceCardView(
                            balanceData: viewModel.balanceData(
                                accounts: accounts,
                                transactions: transactions
                            ),
                            periodFilter: viewModel.periodFilter,
                            onSelectPeriod: viewModel.changePeriod,
                            onPreviousPeriod: viewModel.goToPreviousPeriod,
                            onNextPeriod: viewModel.goToNextPeriod
                        )

                        TransactionsListView(
                            sections: viewModel.groupedTransactions(from: transactions),
                            emptyStateHint: viewModel.emptyStateHint,
                            onTransactionTap: viewModel.handleTransactionTap
                        )
                    }
                    .padding(.bottom, AppSpacing.tabBarBottomInset)
                }
            }
            .background(AppColor.background)
            .navigationBarHidden(true)
            .sheet(item: $viewModel.selectedTransaction) { transaction in
                AddTransactionView(transaction: transaction, accountSelection: accountSelection)
            }
            .onAppear {
                viewModel.syncSelectedAccount(with: accounts)
            }
            .onChange(of: accounts) { _, newAccounts in
                viewModel.syncSelectedAccount(with: newAccounts)
            }
            .sheet(isPresented: $viewModel.showingAccountsView) {
                AccountSelectionSheet(
                    accounts: accounts,
                    selectedAccount: viewModel.selectedAccount,
                    onSelect: { account in
                        viewModel.selectAccount(account)
                    },
                    onShowAll: {
                        viewModel.hideAccounts()
                    }
                )
            }
        }
    }
}

// MARK: - Subviews
private extension DashboardView {

    var accountPickerHeader: some View {
        HStack(spacing: AppSpacing.medium) {
            AccountPickerButton(
                selectedAccount: viewModel.selectedAccount,
                totalBalance: viewModel.totalBalanceData(
                    accounts: accounts,
                    transactions: transactions
                ).balance,
                action: {
                    viewModel.showAccounts()
                }
            )
            Spacer()
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.small)
        .background(AppColor.background)
    }
}

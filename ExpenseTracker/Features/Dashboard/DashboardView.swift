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

    @StateObject private var viewModel = DashboardViewModel()

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
                            )
                        )

                        TransactionsListView(
                            sections: viewModel.groupedTransactions(from: transactions),
                            onTransactionTap: viewModel.handleTransactionTap
                        )
                    }
                    .padding(.bottom, 100)
                }
            }
            .background(AppColor.background)
            .navigationBarHidden(true)
            .fullScreenCover(item: $viewModel.selectedTransaction) { transaction in
                AddTransactionView(transaction: transaction)
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
        HStack(spacing: 12) {
            AccountPickerButton(
                selectedAccount: viewModel.selectedAccount,
                totalBalance: viewModel.balanceData(
                    accounts: accounts,
                    transactions: transactions
                ).balance,
                action: {
                    viewModel.showAccounts()
                }
            )
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppColor.background)
    }
}

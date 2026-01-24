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
    
    @State private var selectedTransaction: Transaction?
    @State private var selectedAccount: Account?
    @State private var showingAccountsView = false
    @Environment(\.tabBarVisibility) private var isTabBarVisible
    
    // MARK: - Computed Properties
    
    private var filteredTransactions: [Transaction] {
        if let selectedAccount = selectedAccount {
            return transactions.filter { $0.account?.id == selectedAccount.id }
        }
        return transactions
    }
    
    private var balanceData: BalanceData {
        if let selectedAccount = selectedAccount {
            return BalanceData(accounts: [selectedAccount])
        } else if !accounts.isEmpty {
            return BalanceData(accounts: accounts)
        } else {
            return BalanceData(transactions: transactions)
        }
    }
    
    private var groupedTransactions: [TransactionSection] {
        TransactionSection.group(filteredTransactions)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                accountPickerHeader
                
                ScrollView {
                    VStack(spacing: .zero) {
                        BalanceCardView(balanceData: balanceData)
                        
                        TransactionsListView(
                            sections: groupedTransactions,
                            onTransactionTap: handleTransactionTap
                        )
                    }
                    .padding(.bottom, 100)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedTransaction) { transaction in
                AddTransactionView(transaction: transaction)
            }
            .sheet(isPresented: $showingAccountsView) {
                AccountSelectionSheet(
                    accounts: accounts,
                    selectedAccount: selectedAccount,
                    onSelect: { account in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedAccount = account
                        }
                        showingAccountsView = false
                    },
                    onShowAll: {
                        showingAccountsView = false
                    }
                )
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleTransactionTap(_ transaction: Transaction) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation {
            selectedTransaction = transaction
        }
    }
}

// MARK: - Account Picker Header
private extension DashboardView {
    
    var accountPickerHeader: some View {
        HStack(spacing: 12) {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showingAccountsView = true
            } label: {
                HStack(spacing: 8) {
                    if let selectedAccount = selectedAccount {
                        ZStack {
                            Circle()
                                .fill(selectedAccount.swiftUIColor.opacity(0.2))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: selectedAccount.icon)
                                .font(.system(size: 16))
                                .foregroundStyle(selectedAccount.swiftUIColor)
                        }
                        
                        AppText(selectedAccount.name, style: .section)
                            .color(.primary)
                    } else {
                        Image(systemName: "square.stack.3d.up.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.blue)
                        
                        AppText("Все счета", style: .section)
                            .color(.primary)
                    }
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
    }
}


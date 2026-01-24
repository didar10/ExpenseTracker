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
    
    @State private var selectedTransaction: Transaction?
    @Environment(\.tabBarVisibility) private var isTabBarVisible
    
    // MARK: - Computed Properties
    
    private var balanceData: BalanceData {
        BalanceData(transactions: transactions)
    }
    
    private var groupedTransactions: [TransactionSection] {
        TransactionSection.group(transactions)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HeaderView(title: "Главная")
                
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

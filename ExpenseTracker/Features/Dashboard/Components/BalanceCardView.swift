//
//  BalanceCardView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Компонент карточки баланса с отображением доходов и расходов
struct BalanceCardView: View {
    let balanceData: BalanceData
    
    var body: some View {
        VStack(spacing: 12) {
            AppText("Баланс", style: .caption, color: .secondary)
            
            // Применяем .rounded design на уровне view
            Text(balanceData.balance.formatted(.currency(code: "KZT")))
                .font(.app(.balance))
                .fontDesign(.rounded)
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
            
            HStack(spacing: 24) {
                FinancialIndicatorView(
                    icon: "arrow.down.circle.fill",
                    color: .green,
                    amount: balanceData.totalIncome
                )
                
                FinancialIndicatorView(
                    icon: "arrow.up.circle.fill",
                    color: .red,
                    amount: balanceData.totalExpenses
                )
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 24)
        .padding(.horizontal)
    }
}

#Preview {
    let mockTransactions: [Transaction] = []
    let balanceData = BalanceData(transactions: mockTransactions)
    
    return BalanceCardView(balanceData: balanceData)
        .background(Color(.systemGroupedBackground))
}

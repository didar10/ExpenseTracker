//
//  FinancialIndicatorView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Компонент для отображения финансового показателя (доход/расход)
struct FinancialIndicatorView: View {
    let icon: String
    let color: Color
    let amount: Decimal
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
            
            Text(amount.formatted(.currency(code: "KZT")))
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
        }
    }
}

#Preview("Income") {
    FinancialIndicatorView(
        icon: "arrow.down.circle.fill",
        color: .green,
        amount: 150000
    )
}

#Preview("Expense") {
    FinancialIndicatorView(
        icon: "arrow.up.circle.fill",
        color: .red,
        amount: 75000
    )
}

//
//  TotalExpensesCardView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Карточка с общей суммой расходов
struct TotalExpensesCardView: View {
    let amount: Decimal
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Всего расходов")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
            
            Text(amount.formatted(.currency(code: "KZT")))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}

#Preview {
    VStack {
        TotalExpensesCardView(amount: 450000)
        TotalExpensesCardView(amount: 0)
    }
    .background(Color(.systemGroupedBackground))
}

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
            AppText("Всего расходов", style: .caption, color: .secondary)
            
            // Используем .rounded для сумм
            Text(amount.formatted(.currency(code: "KZT")))
                .font(.app(.largeTitle))
                .fontDesign(.rounded)
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

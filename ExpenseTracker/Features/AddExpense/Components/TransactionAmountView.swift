//
//  TransactionAmountView.swift
//  ExpenseTracker
//
//  Created by Didar on 23.01.2026.
//

import SwiftUI

struct TransactionAmountView: View {
    let amount: String
    
    var body: some View {
        VStack(spacing: 8) {
            // Сумма
            HStack(spacing: 4) {
                Text(amount.isEmpty ? "0" : amount)
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                AppText("₸", style: .title, color: .secondary)
                    .offset(y: -4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .contentTransition(.numericText())
    }
}

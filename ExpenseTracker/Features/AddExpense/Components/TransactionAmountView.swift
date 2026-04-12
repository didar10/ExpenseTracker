//
//  TransactionAmountView.swift
//  ExpenseTracker
//
//  Created by Didar on 23.01.2026.
//

import SwiftUI

struct TransactionAmountView: View {

    // MARK: - Properties

    let amount: String

    // MARK: - Body

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Text(amount.isEmpty ? "0" : amount)
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                AppText(AppString.currencySymbol, style: .title, color: AppColor.textSecondary)
                    .offset(y: -4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .contentTransition(.numericText())
    }
}

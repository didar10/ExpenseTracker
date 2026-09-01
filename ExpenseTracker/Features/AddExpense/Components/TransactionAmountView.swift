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
    /// Пока сумму не начали вводить, «0» показывается приглушенно — это плейсхолдер, а не значение
    let hasInput: Bool

    // MARK: - Computed Properties

    private var amountColor: Color {
        hasInput ? AppColor.textPrimary : AppColor.textTertiary
    }

    // MARK: - Body

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.smaller) {
            Text(amount)
                .font(.system(size: AppSize.amountDisplay, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(amountColor)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .contentTransition(.numericText())
                .animation(.snappy(duration: 0.2), value: amount)

            AppText(AppString.currencySymbol, style: .title, color: AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.medium)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AppString.accessibilityAmount)
        .accessibilityValue(amount)
    }
}

#Preview {
    VStack(spacing: AppSpacing.xLarge) {
        TransactionAmountView(amount: "0", hasInput: false)
        TransactionAmountView(amount: "1 350 000.75", hasInput: true)
    }
    .background(AppColor.background)
}

//
//  FinancialIndicatorView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

struct FinancialIndicatorView: View {

    // MARK: - Properties

    let icon: Image
    let color: Color
    let amount: Decimal
    /// Подпись для VoiceOver: на экране показателя различает только цвет стрелки
    let accessibilityTitle: String

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.smaller) {
            icon
                .font(.system(size: AppSize.glyphLarge))
                .foregroundStyle(color)

            Text(amount.formatted(.currency(code: AppString.currencyCode)))
                .font(.app(.bodySmall))
                .fontDesign(.rounded)
                .monospacedDigit()
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .contentTransition(.numericText())
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityTitle)
        .accessibilityValue(amount.formatted(.currency(code: AppString.currencyCode)))
    }
}

#Preview {
    HStack(spacing: AppSpacing.xxLarge) {
        FinancialIndicatorView(
            icon: AppImage.incomeArrow,
            color: AppColor.income,
            amount: 150000,
            accessibilityTitle: AppString.incomes
        )

        FinancialIndicatorView(
            icon: AppImage.expenseArrow,
            color: AppColor.expense,
            amount: 75000,
            accessibilityTitle: AppString.expenses
        )
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

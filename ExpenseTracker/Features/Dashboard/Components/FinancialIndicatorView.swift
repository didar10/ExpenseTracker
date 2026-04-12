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

    // MARK: - Body

    var body: some View {
        HStack(spacing: 6) {
            icon
                .font(.system(size: 16))
                .foregroundStyle(color)

            Text(amount.formatted(.currency(code: AppString.currencyCode)))
                .font(.app(.bodySmall))
                .fontDesign(.rounded)
                .foregroundStyle(AppColor.textPrimary)
        }
    }
}

#Preview("Income") {
    FinancialIndicatorView(
        icon: AppImage.incomeArrow,
        color: AppColor.income,
        amount: 150000
    )
}

#Preview("Expense") {
    FinancialIndicatorView(
        icon: AppImage.expenseArrow,
        color: AppColor.expense,
        amount: 75000
    )
}

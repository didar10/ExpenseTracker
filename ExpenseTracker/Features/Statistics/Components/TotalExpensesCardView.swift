//
//  TotalExpensesCardView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Карточка с общей суммой расходов
struct TotalExpensesCardView: View {

    // MARK: - Properties

    let amount: Decimal

    // MARK: - Body

    var body: some View {
        VStack(spacing: AppSpacing.small) {
            AppText(AppString.totalExpenses, style: .caption, color: AppColor.textSecondary)

            Text(amount.formatted(.currency(code: AppString.currencyCode)))
                .font(.app(.largeTitle))
                .fontDesign(.rounded)
                .foregroundStyle(AppColor.textPrimary)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.large)
    }
}

#Preview {
    VStack {
        TotalExpensesCardView(amount: 450000)
        TotalExpensesCardView(amount: 0)
    }
    .background(AppColor.background)
}

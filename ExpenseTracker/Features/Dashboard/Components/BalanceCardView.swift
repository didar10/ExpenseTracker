//
//  BalanceCardView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

struct BalanceCardView: View {

    // MARK: - Properties

    let balanceData: BalanceData

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            AppText(AppString.balance, style: .caption, color: AppColor.textSecondary)

            Text(balanceData.balance.formatted(.currency(code: AppString.currencyCode)))
                .font(.app(.balance))
                .fontDesign(.rounded)
                .foregroundStyle(AppColor.textPrimary)
                .contentTransition(.numericText())

            HStack(spacing: 24) {
                FinancialIndicatorView(
                    icon: AppImage.incomeArrow,
                    color: AppColor.income,
                    amount: balanceData.totalIncome
                )

                FinancialIndicatorView(
                    icon: AppImage.expenseArrow,
                    color: AppColor.expense,
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
        .background(AppColor.background)
}

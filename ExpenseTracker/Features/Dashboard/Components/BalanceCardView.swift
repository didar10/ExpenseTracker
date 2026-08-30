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
    let periodFilter: PeriodFilter
    let onSelectPeriod: (StatisticsPeriod) -> Void
    let onPreviousPeriod: () -> Void
    let onNextPeriod: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: AppSpacing.medium) {
            BalancePeriodSelectorView(
                filter: periodFilter,
                onSelect: onSelectPeriod,
                onPrevious: onPreviousPeriod,
                onNext: onNextPeriod
            )

            Text(balanceData.balance.formatted(.currency(code: AppString.currencyCode)))
                .font(.app(.balance))
                .fontDesign(.rounded)
                .foregroundStyle(AppColor.textPrimary)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(Constants.minAmountScaleFactor)

            HStack(spacing: AppSpacing.xxLarge) {
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
            .padding(.top, AppSpacing.xSmall)
        }
        .padding(.vertical, AppSpacing.xxLarge)
        .padding(.horizontal, AppSpacing.large)
    }
}

// MARK: - Constants

private extension BalanceCardView {

    enum Constants {
        static let minAmountScaleFactor: CGFloat = 0.6
    }
}

#Preview {
    BalanceCardView(
        balanceData: BalanceData(transactions: []),
        periodFilter: PeriodFilter(),
        onSelectPeriod: { _ in },
        onPreviousPeriod: {},
        onNextPeriod: {}
    )
    .background(AppColor.background)
}

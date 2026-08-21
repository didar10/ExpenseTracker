//
//  TotalBudgetCard.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI

struct TotalBudgetCard: View {

    // MARK: - Properties

    let totalBudget: Decimal
    let totalSpent: Decimal

    // MARK: - Computed Properties

    private var progress: Double {
        guard totalBudget > 0 else { return 0 }
        return min(Double(truncating: totalSpent as NSDecimalNumber) / Double(truncating: totalBudget as NSDecimalNumber), 1.0)
    }

    private var percentage: Int {
        guard totalBudget > 0 else { return 0 }
        return Int(truncating: min(totalSpent / totalBudget * 100, 100) as NSDecimalNumber)
    }

    private var remaining: Decimal {
        totalBudget - totalSpent
    }

    private var progressColor: Color {
        switch progress {
        case 0..<0.7: return AppColor.income
        case 0.7..<0.9: return AppColor.warning
        default: return AppColor.expense
        }
    }

    // MARK: - Body

    var body: some View {
        AppCardView {
            VStack(spacing: AppSpacing.large) {
                amountsRow

                progressBar

                summaryRow
            }
        }
    }
}

// MARK: - Subviews
private extension TotalBudgetCard {

    var amountsRow: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                AppText(AppString.totalBudget, style: .caption, color: AppColor.textSecondary)

                Text(totalBudget.formatted(.currency(code: AppString.currencyCode)))
                    .font(.app(.title))
                    .fontDesign(.rounded)
                    .foregroundStyle(AppColor.textPrimary)
                    .contentTransition(.numericText())
            }

            Spacer()

            VStack(alignment: .trailing, spacing: AppSpacing.xSmall) {
                AppText(AppString.spent, style: .caption, color: AppColor.textSecondary)

                Text(totalSpent.formatted(.currency(code: AppString.currencyCode)))
                    .font(.app(.title))
                    .fontDesign(.rounded)
                    .foregroundStyle(totalSpent > totalBudget ? AppColor.expense : AppColor.income)
                    .contentTransition(.numericText())
            }
        }
    }

    var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppColor.subtleFill)

                Capsule()
                    .fill(progressColor)
                    .frame(width: max(geometry.size.width * progress, 0))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(height: AppSpacing.small)
    }

    var summaryRow: some View {
        HStack {
            Text("\(percentage)%")
                .font(.app(.caption))
                .fontDesign(.rounded)
                .foregroundStyle(AppColor.textSecondary)

            Spacer()

            if remaining >= 0 {
                Text("\(AppString.remaining) \(remaining.formatted(.currency(code: AppString.currencyCode)))")
                    .font(.app(.caption))
                    .fontDesign(.rounded)
                    .foregroundStyle(AppColor.textSecondary)
            } else {
                Text("\(AppString.exceeded) \(abs(remaining).formatted(.currency(code: AppString.currencyCode)))")
                    .font(.app(.caption))
                    .fontDesign(.rounded)
                    .foregroundStyle(AppColor.expense)
            }
        }
    }
}

#Preview {
    TotalBudgetCard(totalBudget: 500000, totalSpent: 250000)
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

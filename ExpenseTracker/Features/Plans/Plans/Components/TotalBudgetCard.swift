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
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    AppText(AppString.totalBudget, style: .bodySmall, color: AppColor.textSecondary)

                    Text(totalBudget.formatted(.currency(code: AppString.currencyCode)))
                        .font(.system(size: 26, weight: .bold))
                        .fontDesign(.rounded)
                        .foregroundStyle(AppColor.textPrimary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    AppText(AppString.spent, style: .bodySmall, color: AppColor.textSecondary)

                    Text(totalSpent.formatted(.currency(code: AppString.currencyCode)))
                        .font(.system(size: 22, weight: .bold))
                        .fontDesign(.rounded)
                        .foregroundStyle(totalSpent > totalBudget ? AppColor.expense : AppColor.income)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray6))

                    Capsule()
                        .fill(progressColor)
                        .frame(width: max(geometry.size.width * progress, 0))
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 8)

            HStack(alignment: .center) {
                Text("\(percentage)%")
                    .font(.app(.bodySmall))
                    .foregroundStyle(AppColor.textSecondary)

                Spacer()

                if remaining >= 0 {
                    Text("\(AppString.remaining) \(remaining.formatted(.currency(code: AppString.currencyCode)))")
                        .font(.app(.bodySmall))
                        .foregroundStyle(AppColor.textSecondary)
                } else {
                    Text("\(AppString.exceeded) \(abs(remaining).formatted(.currency(code: AppString.currencyCode)))")
                        .font(.app(.bodySmall))
                        .foregroundStyle(AppColor.expense)
                }
            }
        }
        .padding(16)
        .cardShadow(cornerRadius: 16)
    }
}

#Preview {
    TotalBudgetCard(totalBudget: 500000, totalSpent: 250000)
        .padding()
        .background(AppColor.background)
}

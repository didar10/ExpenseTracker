//
//  BudgetPlanRow.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI

struct BudgetPlanRow: View {

    // MARK: - Properties

    let plan: BudgetPlan
    let spent: Decimal
    let onDelete: () -> Void

    // MARK: - Computed Properties

    private var progress: Double {
        guard plan.monthlyLimit > 0 else { return 0 }
        return min(Double(truncating: spent as NSDecimalNumber) / Double(truncating: plan.monthlyLimit as NSDecimalNumber), 1.0)
    }

    private var percentage: Int {
        guard plan.monthlyLimit > 0 else { return 0 }
        return Int(truncating: min(spent / plan.monthlyLimit * 100, 100) as NSDecimalNumber)
    }

    private var remaining: Decimal {
        plan.monthlyLimit - spent
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
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: plan.category.colorHex).opacity(0.15))
                        .frame(width: 38, height: 38)

                    Image(systemName: plan.category.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(hex: plan.category.colorHex))
                        .symbolRenderingMode(.hierarchical)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(plan.category.name)
                        .font(.app(.bodySmall))

                    Text("\(spent.formatted(.currency(code: AppString.currencyCode))) из \(plan.monthlyLimit.formatted(.currency(code: AppString.currencyCode)))")
                        .font(.app(.microCaption))
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer()

                HStack(spacing: 12) {
                    Text("\(percentage)%")
                        .font(.system(size: 15, weight: .bold))
                        .fontDesign(.rounded)
                        .foregroundStyle(progressColor)

                    Button(action: onDelete) {
                        AppImage.trashFill
                            .font(.system(size: 15))
                            .foregroundStyle(AppColor.expense.opacity(0.8))
                    }
                    .buttonStyle(.plain)
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
            .frame(height: 6)

            HStack {
                if remaining >= 0 {
                    Text("\(AppString.remaining) \(remaining.formatted(.currency(code: AppString.currencyCode)))")
                        .font(.app(.microCaption))
                        .foregroundStyle(.tertiary)
                } else {
                    Text("\(AppString.exceeded) \(abs(remaining).formatted(.currency(code: AppString.currencyCode)))")
                        .font(.app(.microCaption))
                        .foregroundStyle(AppColor.expense)
                }

                Spacer()
            }
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

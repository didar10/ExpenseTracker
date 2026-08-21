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
    let isEditing: Bool
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
        VStack(spacing: AppSpacing.medium) {
            HStack(spacing: AppSpacing.medium) {
                iconBadge

                VStack(alignment: .leading, spacing: AppSpacing.xxSmall) {
                    AppText(plan.category.name, style: .bodySmall)

                    Text("\(spent.formatted(.currency(code: AppString.currencyCode))) \(AppString.outOf) \(plan.monthlyLimit.formatted(.currency(code: AppString.currencyCode)))")
                        .font(.app(.microCaption))
                        .fontDesign(.rounded)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer()

                trailingAccessories
            }

            progressBar

            HStack {
                remainingLabel

                Spacer()
            }
        }
        .padding(.vertical, AppSpacing.medium)
        .contentShape(Rectangle())
    }
}

// MARK: - Subviews
private extension BudgetPlanRow {

    var iconBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .fill(Color(hex: plan.category.colorHex).opacity(0.2))
                .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)

            Image(systemName: plan.category.icon)
                .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
        }
    }

    @ViewBuilder
    var trailingAccessories: some View {
        HStack(spacing: AppSpacing.medium) {
            Text("\(percentage)%")
                .font(.app(.bodySmall))
                .fontDesign(.rounded)
                .foregroundStyle(progressColor)

            if isEditing {
                deleteButton
            }
        }
    }

    var deleteButton: some View {
        Button(action: onDelete) {
            AppImage.trash
                .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .fill(AppColor.expense.opacity(0.15))
                )
        }
        .buttonStyle(.plain)
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
        .frame(height: AppSpacing.smaller)
    }

    @ViewBuilder
    var remainingLabel: some View {
        if remaining >= 0 {
            Text("\(AppString.remaining) \(remaining.formatted(.currency(code: AppString.currencyCode)))")
                .font(.app(.microCaption))
                .fontDesign(.rounded)
                .foregroundStyle(.tertiary)
        } else {
            Text("\(AppString.exceeded) \(abs(remaining).formatted(.currency(code: AppString.currencyCode)))")
                .font(.app(.microCaption))
                .fontDesign(.rounded)
                .foregroundStyle(AppColor.expense)
        }
    }
}

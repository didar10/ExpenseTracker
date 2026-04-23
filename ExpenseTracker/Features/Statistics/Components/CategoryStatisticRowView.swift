//
//  CategoryStatisticRowView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Строка со статистикой категории
struct CategoryStatisticRowView: View {

    // MARK: - Properties

    let statistic: CategoryStatistic
    let totalExpenses: Decimal

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            categoryIcon

            categoryInfo

            Spacer()

            amountInfo
        }
        .padding(.vertical, AppSpacing.smaller)
        .contentShape(Rectangle())
    }
}

// MARK: - Subviews

private extension CategoryStatisticRowView {

    var categoryIcon: some View {
        ZStack {
            Circle()
                .fill(Color(hex: statistic.category.colorHex).opacity(0.15))
                .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)

            Image(systemName: statistic.category.icon)
                .foregroundStyle(Color(hex: statistic.category.colorHex))
                .font(.system(size: AppSize.glyphXLarge, weight: .semibold))
        }
        .circleShadow()
    }

    var categoryInfo: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxSmall) {
            AppText(statistic.category.name, style: .bodySmaller)

            AppText(
                statistic.percentageString(of: totalExpenses),
                style: .microCaption,
                color: AppColor.textSecondary
            )
        }
    }

    var amountInfo: some View {
        HStack(spacing: AppSpacing.small) {
            Text(statistic.amount.formatted(.currency(code: AppString.currencyCode)))
                .font(.app(.bodySmaller))
                .fontDesign(.rounded)
                .foregroundStyle(AppColor.textPrimary)

            AppImage.chevronRight
                .font(.system(size: AppSize.glyphSmall, weight: .semibold))
                .foregroundStyle(AppColor.textTertiary)
        }
    }
}

#Preview {
    CategoryStatisticRowView(
        statistic: CategoryStatistic(
            category: Category(name: "Продукты", icon: "cart.fill", colorHex: "FF6B6B"),
            amount: 125000,
            transactionCount: 15
        ),
        totalExpenses: 450000
    )
    .padding(AppSpacing.large)
}

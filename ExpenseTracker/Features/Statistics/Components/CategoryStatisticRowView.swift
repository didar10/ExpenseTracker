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
    let totalAmount: Decimal

    // MARK: - Computed Properties

    private var amountText: String {
        statistic.amount.formatted(.currency(code: AppString.currencyCode))
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            categoryIcon

            categoryInfo

            Spacer(minLength: AppSpacing.small)

            amountInfo
        }
        .padding(.vertical, AppSpacing.smaller)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(statistic.category.name)
        .accessibilityValue("\(amountText), \(statistic.percentageString(of: totalAmount))")
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
                .lineLimit(1)

            AppText(
                statistic.percentageString(of: totalAmount),
                style: .microCaption,
                color: AppColor.textSecondary
            )
        }
    }

    var amountInfo: some View {
        HStack(spacing: AppSpacing.small) {
            Text(amountText)
                .font(.app(.bodySmaller))
                .fontDesign(.rounded)
                .monospacedDigit()
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

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
        totalAmount: 450000
    )
    .padding(AppSpacing.large)
}

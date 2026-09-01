//
//  CategoryStatisticsListView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Список категорий со статистикой
struct CategoryStatisticsListView: View {

    // MARK: - Properties

    let statistics: [CategoryStatistic]
    let totalAmount: Decimal
    let onCategoryTap: (CategoryStatistic) -> Void

    // MARK: - Body

    var body: some View {
        LazyVStack(spacing: AppSpacing.small) {
            ForEach(statistics) { statistic in
                Button {
                    onCategoryTap(statistic)
                } label: {
                    CategoryStatisticRowView(
                        statistic: statistic,
                        totalAmount: totalAmount
                    )
                    .padding(.horizontal, AppSpacing.large)
                    .padding(.vertical, AppSpacing.medium)
                    .cardShadow(cornerRadius: AppRadius.card)
                }
                .buttonStyle(HighlightRowButtonStyle())
            }
        }
    }
}

#Preview {
    CategoryStatisticsListView(
        statistics: [
            CategoryStatistic(
                category: Category(name: "Продукты", icon: "cart.fill", colorHex: "FF6B6B"),
                amount: 125000,
                transactionCount: 15
            ),
            CategoryStatistic(
                category: Category(name: "Транспорт", icon: "car.fill", colorHex: "4ECDC4"),
                amount: 85000,
                transactionCount: 8
            )
        ],
        totalAmount: 450000,
        onCategoryTap: { _ in }
    )
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

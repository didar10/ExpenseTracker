//
//  CategoryStatisticsListView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Список категорий со статистикой
struct CategoryStatisticsListView: View {
    let statistics: [CategoryStatistic]
    let totalExpenses: Decimal
    let selectedPeriod: StatisticsPeriod
    let onCategoryTap: (CategoryStatistic) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(statistics) { stat in
                Button {
                    onCategoryTap(stat)
                } label: {
                    CategoryStatisticRowView(
                        statistic: stat,
                        totalExpenses: totalExpenses
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .cardShadow(cornerRadius: 16)
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
        totalExpenses: 450000,
        selectedPeriod: .month,
        onCategoryTap: { _ in }
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

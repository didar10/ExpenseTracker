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
        VStack(spacing: 0) {
            ForEach(Array(statistics.enumerated()), id: \.element.id) { index, stat in
                Button {
                    onCategoryTap(stat)
                } label: {
                    CategoryStatisticRowView(
                        statistic: stat,
                        totalExpenses: totalExpenses
                    )
                }
                .buttonStyle(.plain)
                
                if index < statistics.count - 1 {
                    Divider()
                        .padding(.leading, 60)
                }
            }
        }
        .padding(16)
        .cardShadow(cornerRadius: 20)
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

//
//  ExpensesPieChartView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI
import Charts

/// Круговая диаграмма расходов по категориям
struct ExpensesPieChartView: View {
    let statistics: [CategoryStatistic]
    let totalExpenses: Decimal
    
    var body: some View {
        VStack(spacing: 16) {
            Chart {
                ForEach(statistics) { stat in
                    SectorMark(
                        angle: .value("Сумма", stat.amount),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(Color(hex: stat.category.colorHex).gradient)
                    .annotation(position: .overlay) {
                        if shouldShowAnnotation(for: stat) {
                            Image(systemName: stat.category.icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                                .shadow(radius: 2)
                        }
                    }
                }
            }
            .frame(height: 300)
            .chartBackground { _ in
                VStack(spacing: 4) {
                    AppText("Расходы", style: .microCaption, color: .secondary)
                    
                    // Используем .rounded для сумм
                    Text(totalExpenses.formatted(.currency(code: "KZT")))
                        .font(.system(size: 20, weight: .semibold))
                        .fontDesign(.rounded)
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func shouldShowAnnotation(for stat: CategoryStatistic) -> Bool {
        stat.percentage(of: totalExpenses) > 0.12
    }
}

#Preview {
    ExpensesPieChartView(
        statistics: [],
        totalExpenses: 450000
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

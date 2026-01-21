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
        VStack(spacing: 12) {
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
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .shadow(radius: 2)
                        }
                    }
                }
            }
            .frame(height: 220)
            .chartBackground { _ in
                VStack(spacing: 3) {
                    Text("Расходы")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Text(totalExpenses.formatted(.currency(code: "KZT")))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
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

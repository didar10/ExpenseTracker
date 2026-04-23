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

    // MARK: - Properties

    let statistics: [CategoryStatistic]
    let totalExpenses: Decimal

    // MARK: - Body

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            Chart {
                ForEach(statistics) { stat in
                    SectorMark(
                        angle: .value(AppString.amount, stat.amount),
                        innerRadius: .ratio(0.6),
                        angularInset: AppSpacing.xxSmall
                    )
                    .foregroundStyle(Color(hex: stat.category.colorHex).gradient)
                    .annotation(position: .overlay) {
                        if shouldShowAnnotation(for: stat) {
                            Image(systemName: stat.category.icon)
                                .font(.system(size: AppSize.glyphXLarge, weight: .semibold))
                                .foregroundStyle(AppColor.textWhite)
                                .shadow(radius: AppSpacing.xxSmall)
                        }
                    }
                }
            }
            .frame(height: AppSize.chartHeight)
            .chartBackground { _ in
                VStack(spacing: AppSpacing.xSmall) {
                    AppText(AppString.expenses, style: .microCaption, color: AppColor.textSecondary)

                    Text(totalExpenses.formatted(.currency(code: AppString.currencyCode)))
                        .font(.app(.title))
                        .fontDesign(.rounded)
                        .foregroundStyle(AppColor.textPrimary)
                }
            }
        }
        .padding(.vertical, AppSpacing.small)
    }

    // MARK: - Private Methods

    private func shouldShowAnnotation(for stat: CategoryStatistic) -> Bool {
        stat.percentage(of: totalExpenses) > 0.12
    }
}

#Preview {
    ExpensesPieChartView(
        statistics: [],
        totalExpenses: 450000
    )
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

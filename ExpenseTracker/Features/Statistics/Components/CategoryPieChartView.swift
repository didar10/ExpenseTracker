//
//  CategoryPieChartView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI
import Charts

/// Круговая диаграмма доходов или расходов по категориям
struct CategoryPieChartView: View {

    // MARK: - Properties

    let statistics: [CategoryStatistic]
    let totalAmount: Decimal
    let title: String

    // MARK: - Body

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            Chart {
                ForEach(statistics) { stat in
                    SectorMark(
                        angle: .value(AppString.amount, stat.amount),
                        innerRadius: .ratio(AppSize.chartInnerRadiusRatio),
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
            // Charts падает при интерполяции секторов, если данные меняются
            // внутри withAnimation, поэтому отключаем анимацию для диаграммы
            .transaction { $0.animation = nil }
            .chartBackground { _ in
                VStack(spacing: AppSpacing.xSmall) {
                    AppText(title, style: .microCaption, color: AppColor.textSecondary)

                    Text(totalAmount.formatted(.currency(code: AppString.currencyCode)))
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
        stat.percentage(of: totalAmount) > 0.12
    }
}

#Preview {
    CategoryPieChartView(
        statistics: [],
        totalAmount: 450000,
        title: AppString.expenses
    )
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

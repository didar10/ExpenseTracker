//
//  StatisticsEmptyChartView.swift
//  ExpenseTracker
//
//  Created by Didar on 26.08.2026.
//

import SwiftUI

/// Незаполненная диаграмма — серый «бублик» на месте круговой диаграммы.
/// Занимает её высоту, чтобы переключатель периода не сдвигался при отсутствии данных
struct StatisticsEmptyChartView: View {

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            let diameter = min(geometry.size.width, geometry.size.height)
            let ringWidth = diameter * (1 - AppSize.chartInnerRadiusRatio) / 2

            Circle()
                .stroke(AppColor.subtleFill, lineWidth: ringWidth)
                .frame(width: diameter - ringWidth, height: diameter - ringWidth)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: AppSize.chartHeight)
        .padding(.vertical, AppSpacing.small)
    }
}

#Preview {
    StatisticsEmptyChartView()
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

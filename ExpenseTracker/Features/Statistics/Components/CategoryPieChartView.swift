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

    /// Угол, выбранный тапом по диаграмме, в единицах домена (суммах категорий)
    @State private var selectedAngle: Double?
    @State private var selectedStatisticID: CategoryStatistic.ID?

    // MARK: - Computed Properties

    private var selectedStatistic: CategoryStatistic? {
        statistics.first { $0.id == selectedStatisticID }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            Chart {
                ForEach(statistics) { stat in
                    SectorMark(
                        angle: .value(AppString.amount, stat.amount),
                        innerRadius: .ratio(AppSize.chartInnerRadiusRatio),
                        outerRadius: .ratio(outerRadiusRatio(for: stat)),
                        angularInset: AppSpacing.xxSmall
                    )
                    .foregroundStyle(Color(hex: stat.category.colorHex).gradient)
                    .opacity(opacity(for: stat))
                    .accessibilityLabel(stat.category.name)
                    .accessibilityValue(accessibilityValue(for: stat))
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
            .chartAngleSelection(value: $selectedAngle)
            // Charts падает при интерполяции секторов, если данные меняются
            // внутри withAnimation, поэтому отключаем анимацию для диаграммы
            .transaction { $0.animation = nil }
            .chartBackground { _ in
                centerContent
            }
            .onChange(of: selectedAngle) { _, newValue in
                handleAngleSelection(newValue)
            }
            .onChange(of: statistics.map(\.id)) { _, _ in
                selectedStatisticID = nil
            }
        }
        .padding(.vertical, AppSpacing.small)
    }

    // MARK: - Actions

    /// Тап по уже выделенному сектору снимает выделение
    private func handleAngleSelection(_ angle: Double?) {
        guard let angle else { return }

        let tappedID = statistic(atAngle: angle)?.id
        selectedStatisticID = tappedID == selectedStatisticID ? nil : tappedID
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // Сбрасываем угол, чтобы повторный тап по тому же сектору всегда срабатывал
        selectedAngle = nil
    }

    // MARK: - Private Methods

    /// Секторы отрисованы подряд, поэтому угол попадает в категорию по накопленной сумме
    private func statistic(atAngle angle: Double) -> CategoryStatistic? {
        var upperBound: Decimal = 0

        for stat in statistics {
            upperBound += stat.amount

            if angle < (upperBound as NSDecimalNumber).doubleValue {
                return stat
            }
        }

        return statistics.last
    }

    private func isSelected(_ stat: CategoryStatistic) -> Bool {
        stat.id == selectedStatisticID
    }

    private func outerRadiusRatio(for stat: CategoryStatistic) -> CGFloat {
        isSelected(stat) ? AppSize.chartSelectedOuterRadiusRatio : AppSize.chartOuterRadiusRatio
    }

    private func opacity(for stat: CategoryStatistic) -> Double {
        guard selectedStatisticID != nil else { return Constants.fullOpacity }
        return isSelected(stat) ? Constants.fullOpacity : Constants.dimmedSectorOpacity
    }

    private func shouldShowAnnotation(for stat: CategoryStatistic) -> Bool {
        stat.percentage(of: totalAmount) > Constants.minAnnotationPercentage
    }

    /// Сектор различается только цветом, поэтому VoiceOver читает сумму и долю
    private func accessibilityValue(for stat: CategoryStatistic) -> String {
        let amount = stat.amount.formatted(.currency(code: AppString.currencyCode))
        return "\(amount), \(stat.percentageString(of: totalAmount))"
    }
}

// MARK: - Constants

private extension CategoryPieChartView {

    enum Constants {
        static let fullOpacity: Double = 1
        static let dimmedSectorOpacity: Double = 0.25
        static let selectedIconBackgroundOpacity: Double = 0.15
        static let minAnnotationPercentage: Double = 0.12
        /// Минимальный коэффициент сжатия текста в центре «бублика»
        static let minTextScaleFactor: CGFloat = 0.7
    }
}

// MARK: - Subviews

private extension CategoryPieChartView {

    @ViewBuilder
    var centerContent: some View {
        if let selectedStatistic {
            selectedCategoryInfo(for: selectedStatistic)
        } else {
            totalInfo
        }
    }

    var totalInfo: some View {
        VStack(spacing: AppSpacing.xSmall) {
            AppText(title, style: .microCaption, color: AppColor.textSecondary)

            Text(totalAmount.formatted(.currency(code: AppString.currencyCode)))
                .font(.app(.title))
                .fontDesign(.rounded)
                .monospacedDigit()
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(Constants.minTextScaleFactor)
        }
        .frame(width: AppSize.chartCenterContentWidth)
    }

    func selectedCategoryInfo(for statistic: CategoryStatistic) -> some View {
        let categoryColor = Color(hex: statistic.category.colorHex)

        return VStack(spacing: AppSpacing.smaller) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(Constants.selectedIconBackgroundOpacity))
                    .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)

                Image(systemName: statistic.category.icon)
                    .font(.system(size: AppSize.glyphXLarge, weight: .semibold))
                    .foregroundStyle(categoryColor)
            }

            AppText(
                statistic.category.name,
                style: .microCaption,
                color: AppColor.textSecondary,
                alignment: .center
            )
            .lineLimit(1)
            .minimumScaleFactor(Constants.minTextScaleFactor)

            Text(statistic.amount.formatted(.currency(code: AppString.currencyCode)))
                .font(.app(.title))
                .fontDesign(.rounded)
                .monospacedDigit()
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(Constants.minTextScaleFactor)

            AppText(
                statistic.percentageString(of: totalAmount),
                style: .captionMedium,
                color: categoryColor
            )
        }
        .frame(width: AppSize.chartCenterContentWidth)
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

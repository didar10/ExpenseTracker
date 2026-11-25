//
//  CategoryDonutChart.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import Charts
import SwiftUI

/// Пончик 300 × 300 по категориям: сегменты цветами категорий с обводкой ink,
/// в центре метка «Расходы» и сумма. Без данных — серое кольцо со штриховкой
struct CategoryDonutChart: View {

    // MARK: - Properties

    let statistics: [CategoryStatistic]
    let total: Decimal
    /// «Расходы» или «Доходы»
    let title: String

    // MARK: - Body

    var body: some View {
        ZStack {
            if statistics.isEmpty {
                EmptyRing()
                    .frame(width: Metrics.emptyDiameter, height: Metrics.emptyDiameter)
            } else {
                chart
            }

            centerLabel
        }
        .frame(width: Metrics.diameter, height: Metrics.diameter)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Subviews

private extension CategoryDonutChart {

    var chart: some View {
        Chart(statistics) { statistic in
            SectorMark(
                angle: .value(AppString.amount, statistic.amount),
                innerRadius: .ratio(Metrics.innerRatio)
            )
            .foregroundStyle(statistic.color.color)
            .accessibilityLabel(statistic.category.name)
            .accessibilityValue("\(MoneyFormat.money(statistic.amount)), \(statistic.percentageString(of: total))")
        }
        .chartLegend(.hidden)
        // Charts падает при интерполяции секторов, если данные меняются внутри withAnimation
        .transaction { $0.animation = nil }
        // SectorMark не умеет обводку — контуры и границы сегментов рисуются поверх
        .overlay {
            SectorOutline(fractions: statistics.map { $0.percentage(of: total) }, innerRatio: Metrics.innerRatio)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }

    var centerLabel: some View {
        VStack(spacing: Metrics.labelSpacing) {
            Text(title)
                .dsLabel()

            Text(MoneyFormat.money(total))
                .font(DS.Font.amountM)
                .foregroundStyle(DS.Color.ink)
                .lineLimit(1)
                .minimumScaleFactor(Metrics.minimumScale)
        }
        // Текст не выходит за внутренний круг
        .frame(maxWidth: Metrics.diameter * Metrics.innerRatio - DS.Spacing.lg)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Outline

/// Внешний и внутренний контур кольца и границы сегментов. Сегменты идут
/// по часовой стрелке от 12 часов — так же, как рисует их `SectorMark`
private struct SectorOutline: View {

    let fractions: [Double]
    let innerRatio: CGFloat

    var body: some View {
        Canvas { context, size in
            let lineWidth = DS.Stroke.regular
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let outer = min(size.width, size.height) / 2 - lineWidth / 2
            let inner = outer * innerRatio
            var path = Path()

            path.addEllipse(in: CGRect(x: center.x - outer, y: center.y - outer, width: outer * 2, height: outer * 2))
            path.addEllipse(in: CGRect(x: center.x - inner, y: center.y - inner, width: inner * 2, height: inner * 2))

            // Одна категория — сплошное кольцо без границ
            if fractions.count > 1 {
                var start = 0.0
                for fraction in fractions {
                    let angle = (start * 2 - 0.5) * .pi
                    path.move(to: CGPoint(x: center.x + inner * cos(angle), y: center.y + inner * sin(angle)))
                    path.addLine(to: CGPoint(x: center.x + outer * cos(angle), y: center.y + outer * sin(angle)))
                    start += fraction
                }
            }

            context.stroke(path, with: .color(DS.Color.ink), lineWidth: lineWidth)
        }
    }
}

// MARK: - Empty Ring

/// Пустое кольцо: штриховка −45° между кругами и пунктирная внешняя обводка — `StatisticsEmpty.html`
private struct EmptyRing: View {

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let outer = min(size.width, size.height) / 2
            let inner = outer * Metrics.innerRatio

            var ring = Path()
            ring.addEllipse(in: CGRect(x: center.x - outer, y: center.y - outer, width: outer * 2, height: outer * 2))
            ring.addEllipse(in: CGRect(x: center.x - inner, y: center.y - inner, width: inner * 2, height: inner * 2))

            context.drawLayer { layer in
                layer.clip(to: ring, style: FillStyle(eoFill: true))

                let step = Metrics.stripeWidth * 2 * Metrics.diagonalFactor
                let base = Metrics.stripeWidth * Metrics.diagonalFactor
                var x = -size.height
                while x < size.width + size.height {
                    var stripe = Path()
                    stripe.move(to: CGPoint(x: x, y: size.height))
                    stripe.addLine(to: CGPoint(x: x + size.height, y: .zero))
                    stripe.addLine(to: CGPoint(x: x + size.height + base, y: .zero))
                    stripe.addLine(to: CGPoint(x: x + base, y: size.height))
                    stripe.closeSubpath()
                    layer.fill(stripe, with: .color(DS.Color.emptyHatch))
                    x += step
                }
            }
        }
        .overlay {
            Circle()
                .strokeBorder(DS.Color.ink, style: StrokeStyle(lineWidth: DS.Stroke.regular, dash: DS.Stroke.dash))
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/Statistics.html` и `StatisticsEmpty.html`
    static let diameter: CGFloat = 300
    static let emptyDiameter: CGFloat = 292
    static let innerRatio: CGFloat = 0.62
    static let labelSpacing: CGFloat = 4
    static let minimumScale: CGFloat = 0.5
    static let stripeWidth: CGFloat = 6
    /// √2: ширина полосы под 45° в проекции на горизонталь
    static let diagonalFactor: CGFloat = 2.squareRoot()
}

// MARK: - Previews

#if DEBUG
#Preview("Данные · светлая") {
    CategoryDonutChart(statistics: StatisticsPreviewData.expenses, total: 131_950, title: AppString.expenses)
        .padding()
        .background(DS.Color.bg)
}

#Preview("Одна категория · темная") {
    CategoryDonutChart(statistics: Array(StatisticsPreviewData.expenses.prefix(1)), total: 65_000, title: AppString.incomes)
        .padding()
        .background(DS.Color.bg)
        .preferredColorScheme(.dark)
}

#Preview("Пусто · светлая") {
    CategoryDonutChart(statistics: [], total: 0, title: AppString.expenses)
        .padding()
        .background(DS.Color.bg)
}

#Preview("Пусто · темная") {
    CategoryDonutChart(statistics: [], total: 0, title: AppString.expenses)
        .padding()
        .background(DS.Color.bg)
        .preferredColorScheme(.dark)
}

/// Категории из макета `Statistics.html`
enum StatisticsPreviewData {

    static let expenses: [CategoryStatistic] = [
        ("Дом", "house", "#AF52DE", 65_000),
        ("Покупки", "bag", "#FF9500", 28_500),
        ("Еда", "cup.and.saucer", "#34C759", 20_650),
        ("Транспорт", "car", "#007AFF", 9_300),
        ("Развлечения", "film", "#FF2D55", 8_500)
    ].map { name, icon, hex, amount in
        CategoryStatistic(category: Category(name: name, icon: icon, colorHex: hex), amount: amount, transactionCount: 1)
    }
}
#endif

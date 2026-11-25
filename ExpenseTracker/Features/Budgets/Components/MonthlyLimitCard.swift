//
//  MonthlyLimitCard.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// «Лимит на месяц»: остаток крупно, составная полоса трат по категориям,
/// сумма на день и плашка темпа. Пилюля с лимитом открывает его настройку.
/// У прошедшего месяца нет суммы на день и темпа
struct MonthlyLimitCard: View {

    // MARK: - Properties

    let overview: MonthlyLimitOverview
    let onEditLimit: () -> Void

    // MARK: - Body

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: .zero) {
                header

                amount
                    .padding(.top, DS.Spacing.sm)

                LimitSpendingBar(segments: overview.segments)
                    .padding(.top, DS.Spacing.md)

                footer
                    .padding(.top, DS.Spacing.sm)

                if let plaque {
                    plaque
                        .padding(.top, DS.Spacing.md)
                }
            }
        }
    }
}

// MARK: - Subviews

private extension MonthlyLimitCard {

    var header: some View {
        HStack {
            Text(AppString.monthlyLimitTitle)
                .dsLabel()
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: DS.Spacing.sm)

            Button(action: onEditLimit) {
                HStack(spacing: DS.Spacing.sm) {
                    AppImage.pencil
                        .font(.system(size: DS.Size.iconXS, weight: .semibold))
                        .accessibilityHidden(true)

                    Text(MoneyFormat.money(overview.limit))
                        .font(DS.Font.captionBold)
                        .lineLimit(1)
                }
                .padding(.horizontal, Metrics.pillPadding)
                .frame(minHeight: Metrics.pillHeight)
            }
            .buttonStyle(.outlineClick)
            .accessibilityLabel(AppString.budgetsEditLimitLabel(MoneyFormat.money(overview.limit)))
        }
    }

    var amount: some View {
        HStack(alignment: .firstTextBaseline, spacing: DS.Spacing.sm) {
            Text(MoneyFormat.money(abs(overview.remaining)))
                .font(DS.Font.amountLimit)
                .foregroundStyle(overview.isExceeded ? DS.Color.danger : DS.Color.ink)
                .lineLimit(1)
                .minimumScaleFactor(Metrics.amountMinimumScale)
                .contentTransition(.numericText())

            Text(overview.isExceeded ? AppString.budgetsOverLimit : AppString.budgetsLeft)
                .font(DS.Font.bodySmall)
                .foregroundStyle(DS.Color.ink2)
                .lineLimit(1)
        }
        .accessibilityElement(children: .combine)
    }

    var footer: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline) {
                spentText
                Spacer(minLength: DS.Spacing.sm)
                perDayText
            }

            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                spentText
                perDayText
            }
        }
    }

    var spentText: some View {
        Text(AppString.budgetsSpent(MoneyFormat.number(overview.spent)))
            .font(DS.Font.moneySmall)
            .foregroundStyle(DS.Color.ink2)
            .lineLimit(1)
    }

    @ViewBuilder
    var perDayText: some View {
        if let perDay = overview.perDay, let daysLeft = overview.daysLeft {
            let amount = MoneyFormat.money(perDay)

            Text(highlighted(AppString.budgetsPerDay(amount, daysLeft), part: amount))
                .font(DS.Font.caption)
                .foregroundStyle(DS.Color.ink2)
                .lineLimit(1)
        }
    }

    /// Темп по плану; при превышении лимита — сколько сверх
    var plaque: PacePlaque? {
        if overview.isExceeded {
            return PacePlaque(
                title: AppString.budgetsPaceLimitExceeded,
                detail: AppString.budgetsPaceExceededBy(MoneyFormat.money(-overview.remaining)),
                fill: DS.Color.dangerFill,
                textColor: DS.Color.onDanger
            )
        }

        guard let pace = overview.pace else { return nil }

        let detail: String
        if pace.percent == 0 {
            detail = AppString.budgetsPaceExact
        } else if pace.isFaster {
            detail = AppString.budgetsPaceFaster(pace.percent)
        } else {
            detail = AppString.budgetsPaceSlower(pace.percent)
        }

        return PacePlaque(
            title: pace.isFaster ? AppString.budgetsPaceFast : AppString.budgetsPaceNormal,
            detail: detail,
            fill: pace.isFaster ? DS.CategoryColor.orange.color : DS.CategoryColor.green.color,
            textColor: DS.Color.ink
        )
    }

    /// Сумма внутри строки выделена жирным цветом ink
    func highlighted(_ text: String, part: String) -> AttributedString {
        var result = AttributedString(text)
        if let range = result.range(of: part) {
            result[range].font = DS.Font.captionBold
            result[range].foregroundColor = DS.Color.ink
        }
        return result
    }
}

// MARK: - Pace Plaque

/// Плашка темпа: жирный заголовок и пояснение одной строкой с переносом
private struct PacePlaque: View {

    // MARK: - Properties

    let title: String
    let detail: String
    let fill: Color
    let textColor: Color

    // MARK: - Body

    var body: some View {
        Text("\(Text(title).font(DS.Font.captionBold)) \(detail)")
            .font(DS.Font.caption)
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, DS.Spacing.sm)
            .padding(.horizontal, Metrics.plaquePadding)
            .background(fill, in: RoundedRectangle(cornerRadius: Metrics.plaqueRadius))
            .brutalBorder(radius: Metrics.plaqueRadius)
    }
}

// MARK: - Limit Spending Bar

/// Составная полоса лимита: отрезки цветами категорий по их тратам, остаток заштрихован
struct LimitSpendingBar: View {

    // MARK: - Properties

    let segments: [SpendingSegment]

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Body

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: .zero) {
                ForEach(segments) { segment in
                    Rectangle()
                        .fill(segment.fill)
                        .frame(width: proxy.size.width * segment.fraction)
                        .overlay(alignment: .trailing) {
                            Rectangle()
                                .fill(DS.Color.ink)
                                .frame(width: DS.Stroke.regular)
                        }
                }

                HatchPattern()
                    .frame(maxWidth: .infinity)
            }
            .animation(reduceMotion ? nil : DS.Motion.toggle, value: segments)
        }
        .frame(height: Metrics.barHeight)
        .background(DS.Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.barRadius))
        .brutalBorder(radius: Metrics.barRadius)
        .accessibilityHidden(true)
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/Budgets.html`
    static let pillHeight: CGFloat = 30
    static let pillPadding: CGFloat = 10
    static let amountMinimumScale: CGFloat = 0.6
    static let barHeight: CGFloat = 22
    static let barRadius: CGFloat = 8
    static let plaquePadding: CGFloat = 10
    static let plaqueRadius: CGFloat = 10
}

// MARK: - Previews

#if DEBUG
extension MonthlyLimitOverview {

    /// Числа из `Budgets.html`: 131 950 из 250 000, 11 дней до конца месяца
    static func preview(spent: Decimal = 131_950, isPast: Bool = false, pace: LimitPace? = LimitPace(percent: 8, isFaster: false)) -> MonthlyLimitOverview {
        let limit: Decimal = 250_000
        let shares: [(DS.CategoryColor?, Decimal)] = [(.orange, 28_500), (.purple, 65_000), (.blue, 9_300), (.green, 20_650), (nil, 8_500)]
        let scale = NSDecimalNumber(decimal: max(limit, spent)).doubleValue
        let factor = NSDecimalNumber(decimal: spent / 131_950).doubleValue

        return MonthlyLimitOverview(
            limit: limit,
            spent: spent,
            segments: shares.enumerated().map { index, share in
                SpendingSegment(id: "\(index)", color: share.0, fraction: NSDecimalNumber(decimal: share.1).doubleValue * factor / scale)
            },
            daysLeft: isPast ? nil : 11,
            perDay: isPast ? nil : BudgetsViewModel.perDay(limit - spent, days: 11),
            pace: isPast ? nil : pace
        )
    }
}

private struct MonthlyLimitCardGallery: View {

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Темп в норме") {
                MonthlyLimitCard(overview: .preview()) {}
            }
            DSPreviewCase("Темп выше плана") {
                MonthlyLimitCard(overview: .preview(spent: 190_000, pace: LimitPace(percent: 14, isFaster: true))) {}
            }
            DSPreviewCase("Лимит превышен") {
                MonthlyLimitCard(overview: .preview(spent: 262_000, pace: LimitPace(percent: 57, isFaster: true))) {}
            }
            DSPreviewCase("Прошлый месяц") {
                MonthlyLimitCard(overview: .preview(spent: 231_400, isPast: true)) {}
            }
        }
    }
}

#Preview("Светлая") {
    MonthlyLimitCardGallery()
}

#Preview("Темная") {
    MonthlyLimitCardGallery()
        .preferredColorScheme(.dark)
}
#endif

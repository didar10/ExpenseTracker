//
//  CategoryBreakdownList.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// «По категориям» + количество, под ним карточка-список: плитка, название, полоса доли
/// цветом категории (длина — относительно самой большой), сумма и процент.
/// Тап открывает операции категории
struct CategoryBreakdownList: View {

    // MARK: - Properties

    let statistics: [CategoryStatistic]
    let total: Decimal
    let type: TransactionType
    let onSelect: (CategoryStatistic) -> Void

    // MARK: - Body

    var body: some View {
        let maxAmount = statistics.map(\.amount).max() ?? .zero

        VStack(spacing: .zero) {
            header

            Card(padding: nil) {
                VStack(spacing: .zero) {
                    ForEach(Array(statistics.enumerated()), id: \.element.id) { index, statistic in
                        if index > .zero {
                            ListDivider()
                        }

                        row(statistic, maxAmount: maxAmount)
                    }
                }
            }
        }
    }
}

// MARK: - Subviews

private extension CategoryBreakdownList {

    var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(AppString.byCategories)
                .dsLabel()
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: DS.Spacing.sm)

            Text(String(statistics.count))
                .font(DS.Font.moneySmall)
                .foregroundStyle(DS.Color.ink2)
        }
        .padding(.horizontal, Metrics.headerInset)
        .padding(.top, Metrics.headerTop)
        .padding(.bottom, DS.Spacing.sm)
    }

    func row(_ statistic: CategoryStatistic, maxAmount: Decimal) -> some View {
        let amount = statistic.signedAmount(for: type)
        let percent = statistic.percentageString(of: total)

        return Button {
            onSelect(statistic)
        } label: {
            HStack(spacing: DS.Spacing.md) {
                CategoryTile(icon: statistic.icon, color: statistic.color, size: .medium)

                VStack(alignment: .leading, spacing: Metrics.barTop) {
                    Text(statistic.category.name)
                        .font(DS.Font.bodyBold)
                        .lineLimit(1)

                    ProgressBar(
                        progress: statistic.barFraction(relativeTo: maxAmount),
                        tint: statistic.color.color,
                        size: .thin
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .trailing, spacing: .zero) {
                    Text(amount)
                        .font(DS.Font.money)
                        .lineLimit(1)

                    Text(percent)
                        .font(DS.Font.moneySmall)
                        .foregroundStyle(DS.Color.ink2)
                }
                .layoutPriority(1)
            }
            .padding(.vertical, DS.Spacing.sm)
            .padding(.leading, DS.Spacing.md)
            .padding(.trailing, Metrics.trailingPadding)
            .frame(minHeight: Metrics.rowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.outlineClickSegment)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(statistic.category.name), \(amount) \(AppString.currencySymbol), \(percent)")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/Statistics.html` (.sec, .li, .prog)
    static let headerTop: CGFloat = 22
    static let headerInset: CGFloat = 2
    static let rowHeight: CGFloat = 56
    static let trailingPadding: CGFloat = 14
    static let barTop: CGFloat = 6
}

// MARK: - Previews

#if DEBUG
#Preview("Расходы · светлая") {
    ScrollView {
        CategoryBreakdownList(statistics: StatisticsPreviewData.expenses, total: 131_950, type: .expense) { _ in }
            .padding(.horizontal, DS.Spacing.xl)
    }
    .background(DS.Color.bg)
}

#Preview("Доходы · темная") {
    ScrollView {
        CategoryBreakdownList(statistics: Array(StatisticsPreviewData.expenses.prefix(3)), total: 114_150, type: .income) { _ in }
            .padding(.horizontal, DS.Spacing.xl)
    }
    .background(DS.Color.bg)
    .preferredColorScheme(.dark)
}
#endif

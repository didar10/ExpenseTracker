//
//  TransactionRow.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Строка операции в списке: плитка категории, название, подпись и сумма моноширинным шрифтом.
/// Суммы приходят отформатированными: «−3 200», «+45 000». Доход — зеленым
struct TransactionRow: View {

    // MARK: - Properties

    let title: String
    var subtitle: String?
    let amount: String
    var isIncome = false
    let icon: Image
    let color: DS.CategoryColor

    // MARK: - Init

    init(
        title: String,
        subtitle: String? = nil,
        amount: String,
        isIncome: Bool = false,
        icon: Image,
        color: DS.CategoryColor
    ) {
        self.title = title
        self.subtitle = subtitle
        self.amount = amount
        self.isIncome = isIncome
        self.icon = icon
        self.color = color
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            CategoryTile(icon: icon, color: color)

            VStack(alignment: .leading, spacing: Metrics.textSpacing) {
                Text(title)
                    .font(DS.Font.bodyBold)
                    .foregroundStyle(DS.Color.ink)
                    .lineLimit(1)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(DS.Font.caption)
                        .foregroundStyle(DS.Color.ink2)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(amount)
                .font(DS.Font.money)
                .foregroundStyle(isIncome ? DS.Color.income : DS.Color.ink)
                .lineLimit(1)
                .layoutPriority(1)
        }
        .padding(.vertical, DS.Spacing.md)
        .padding(.leading, DS.Spacing.md)
        .padding(.trailing, Metrics.trailingPadding)
        .frame(minHeight: DS.Size.row)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/_Components.html` (.row)
    static let textSpacing: CGFloat = 2
    static let trailingPadding: CGFloat = 14
}

// MARK: - Previews

#if DEBUG
private struct TransactionRowGallery: View {

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Расход и доход в списке") {
                Card(padding: nil) {
                    VStack(spacing: .zero) {
                        TransactionRow(title: "Еда", subtitle: "Обед в кафе · Kaspi Gold", amount: "−3 200",
                                       icon: Image(systemName: "cup.and.saucer"), color: .green)
                        ListDivider()
                        TransactionRow(title: "Доход", subtitle: "Дизайн проекта", amount: "+45 000", isIncome: true,
                                       icon: Image(systemName: "banknote"), color: .green)
                    }
                }
            }
            DSPreviewCase("Без подписи") {
                Card(padding: nil) {
                    TransactionRow(title: "Транспорт", amount: "−2 100", icon: Image(systemName: "car"), color: .blue)
                }
            }
            DSPreviewCase("Длинные тексты и сумма") {
                Card(padding: nil) {
                    TransactionRow(title: "Развлечения и отдых с друзьями", subtitle: "Кино, ужин, такси обратно домой · Freedom",
                                   amount: "−1 250 000", icon: Image(systemName: "gift"), color: .pink)
                }
            }
        }
    }
}

#Preview("Светлая") {
    TransactionRowGallery()
}

#Preview("Темная") {
    TransactionRowGallery()
        .preferredColorScheme(.dark)
}
#endif

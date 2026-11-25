//
//  MetaPill.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Невысокая пилюля 34 pt под суммой: счет («Freedom 49 300 ₸») и дата («Сегодня 23:56»).
/// Слева — цветная плашка счета или иконка, затем название и значение моноширинным. Без тени
struct MetaPill: View {

    // MARK: - Types

    enum Leading {
        /// Плашка счета 24×24: иконка белым на цвете счета
        case badge(Image, Color)
        /// Иконка цвета ink без плашки
        case icon(Image)
    }

    // MARK: - Properties

    let leading: Leading
    let title: String
    let value: String
    /// Подсказка VoiceOver: что откроется по нажатию
    let accessibilityHint: String
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            content
        }
        .buttonStyle(.outlineClick)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(value)")
        .accessibilityHint(accessibilityHint)
    }
}

// MARK: - Subviews

extension MetaPill {

    /// Содержимое отдельно от кнопки — для превью нажатого состояния
    var content: some View {
        HStack(spacing: DS.Spacing.sm) {
            leadingView

            Text(title)
                .font(DS.Font.control)
                .lineLimit(1)

            Text(value)
                .font(DS.Font.moneySmall)
                .foregroundStyle(DS.Color.ink2)
                .lineLimit(1)
        }
        .padding(.leading, leadingPadding)
        .padding(.trailing, Metrics.trailingPadding)
        .frame(minHeight: Metrics.height)
    }

    @ViewBuilder
    private var leadingView: some View {
        switch leading {
        case .badge(let image, let color):
            image
                .font(.system(size: DS.Size.iconXS, weight: .semibold))
                .foregroundStyle(DS.Color.onColorFill)
                .frame(width: Metrics.badge, height: Metrics.badge)
                .background(color, in: RoundedRectangle(cornerRadius: Metrics.badgeRadius))
                .brutalBorder(radius: Metrics.badgeRadius)

        case .icon(let image):
            image
                .font(.system(size: DS.Size.iconS, weight: .semibold))
        }
    }

    private var leadingPadding: CGFloat {
        switch leading {
        case .badge: return Metrics.badgeLeadingPadding
        case .icon: return Metrics.trailingPadding
        }
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/AddTransaction.html` (.meta .pill)
    static let height: CGFloat = 34
    static let badge: CGFloat = 24
    static let badgeRadius: CGFloat = 6
    static let badgeLeadingPadding: CGFloat = 6
    static let trailingPadding: CGFloat = 12
}

// MARK: - Previews

#if DEBUG
private struct MetaPillGallery: View {

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Счет и дата") {
                HStack(spacing: DS.Spacing.sm) {
                    MetaPill(
                        leading: .badge(Image(systemName: "creditcard"), DS.CategoryColor.green.color),
                        title: "Freedom",
                        value: "49 300 ₸",
                        accessibilityHint: ""
                    ) {}
                    MetaPill(leading: .icon(DS.Icon.calendar), title: "Сегодня", value: "23:56", accessibilityHint: "") {}
                }
            }
            DSPreviewCase("Нажата") {
                OutlineClickBody(shape: .bordered(radius: DS.Radius.control), fill: DS.Color.surface, isPressed: true) {
                    MetaPill(leading: .icon(DS.Icon.calendar), title: "Вчера", value: "09:15", accessibilityHint: "") {}.content
                }
            }
            DSPreviewCase("Длинное название") {
                MetaPill(
                    leading: .badge(Image(systemName: "banknote"), DS.CategoryColor.orange.color),
                    title: "Депозит на машину",
                    value: "12 450 000 ₸",
                    accessibilityHint: ""
                ) {}
            }
        }
    }
}

#Preview("Светлая") {
    MetaPillGallery()
}

#Preview("Темная") {
    MetaPillGallery()
        .preferredColorScheme(.dark)
}
#endif

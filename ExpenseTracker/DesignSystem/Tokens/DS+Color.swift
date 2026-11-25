//
//  DS+Color.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

extension DS {

    /// Цвета дизайн-системы. Светлый и темный варианты — в `DesignSystem.xcassets/DS`;
    /// значения сверены с `Design/html/_Tokens.html` и `MainDark.html`
    enum Color {
        /// Фон экрана
        static let bg = SwiftUI.Color(Name.bg)
        /// Карточки, списки, поля
        static let surface = SwiftUI.Color(Name.surface)
        /// Основной текст, обводки, жесткие тени
        static let ink = SwiftUI.Color(Name.ink)
        /// Второстепенный текст и метки
        static let ink2 = SwiftUI.Color(Name.ink2)
        /// Разделители строк: ink 12% (в темной теме 14%)
        static let line = SwiftUI.Color(Name.line)
        /// Главное действие и выбранное состояние. Текст на нем — всегда `onAccent`
        static let accent = SwiftUI.Color(Name.accent)
        static let income = SwiftUI.Color(Name.income)
        static let danger = SwiftUI.Color(Name.danger)

        /// Текст и иконки на `accent`: #111 в обеих темах — желтый не темнеет,
        /// а `ink` в темной теме светлый
        static let onAccent = SwiftUI.Color(Name.onAccent)
    }

    /// Плоские заливки плиток категорий
    enum CategoryColor: String, CaseIterable {
        case green
        case blue
        case purple
        case orange
        case pink

        // MARK: - Computed Properties

        var color: SwiftUI.Color {
            SwiftUI.Color(assetName)
        }

        var assetName: String {
            "DS/category\(rawValue.prefix(1).uppercased())\(rawValue.dropFirst())"
        }
    }
}

// MARK: - Asset Names

extension DS.Color {

    enum Name {
        static let bg = "DS/bg"
        static let surface = "DS/surface"
        static let ink = "DS/ink"
        static let ink2 = "DS/ink2"
        static let line = "DS/line"
        static let accent = "DS/accent"
        static let income = "DS/income"
        static let danger = "DS/danger"
        static let onAccent = "DS/onAccent"

        static let all = [bg, surface, ink, ink2, line, accent, income, danger, onAccent]
    }
}

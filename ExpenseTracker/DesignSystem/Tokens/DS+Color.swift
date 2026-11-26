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

        /// Штриховка превышенного прогресса: одинакова в обеих темах, как в макете
        static let overStripeStrong = SwiftUI.Color(Name.overStripeStrong)
        static let overStripeSoft = SwiftUI.Color(Name.overStripeSoft)

        /// Затемнение под алертом и меню: 35% (#111 в светлой теме, черный в темной)
        static let scrim = SwiftUI.Color(Name.scrim)
        /// Заливка кнопки удаления в алерте: #C4281C в обеих темах — белый текст на нем читается (5.6:1)
        static let dangerFill = SwiftUI.Color(Name.dangerFill)
        static let onDanger = SwiftUI.Color(Name.onDanger)
        /// Граббер листа
        static let grabber = SwiftUI.Color(Name.grabber)
        /// Плитка «Без категории»
        static let noCategory = SwiftUI.Color(Name.noCategory)
        /// Плитка перевода в ленте — тот же нейтральный серый, что у «Без категории»
        static let transferTile = SwiftUI.Color(Name.noCategory)
        /// Недоступный день в календаре — будущее
        static let inkDisabled = SwiftUI.Color(Name.inkDisabled)
        /// Иконка на цветной плашке счета: белая в обеих темах
        static let onColorFill = SwiftUI.Color(Name.onColorFill)
        /// Штриховка пустого кольца статистики — `StatisticsEmpty.html`
        static let emptyHatch = SwiftUI.Color(Name.emptyHatch)
        static let accountRed = SwiftUI.Color(Name.accountRed)
    }

    /// Плоские заливки плиток категорий
    enum CategoryColor: String, CaseIterable {
        case green
        case blue
        case purple
        case orange
        case pink
        case yellow, red, teal, lime, cyan, indigo, black

        // MARK: - Computed Properties

        var color: SwiftUI.Color {
            SwiftUI.Color(assetName)
        }

        var foreground: SwiftUI.Color {
            DS.AccountColor(name: rawValue).foreground
        }

        var assetName: String {
            switch self {
            case .yellow: Color.Name.accent
            case .red: Color.Name.accountRed
            case .teal: Color.Name.accountTeal
            case .lime: Color.Name.accountLime
            case .cyan: Color.Name.accountCyan
            case .indigo: Color.Name.accountIndigo
            case .black: Color.Name.onAccent
            default: "DS/category\(rawValue.capitalized)"
            }
        }
    }
}

// MARK: - Legacy Hex

extension DS.CategoryColor {

    /// Цвет плитки для категории, у которой в данных записан hex старой палитры
    /// (#34C759, #007AFF…): ближайший по оттенку токен. Серый и нераспознанный — `.blue`
    init(legacyHex: String) {
        if let exact = DS.AccountColor.allCases.first(where: { $0.categoryHex.caseInsensitiveCompare(legacyHex) == .orderedSame }),
           let color = Self(rawValue: exact.rawValue) {
            self = color
            return
        }
        guard let hue = Self.hue(ofHex: legacyHex) else {
            self = .blue
            return
        }

        self = Self.legacyAnchors.min { lhs, rhs in
            Self.distance(hue, lhs.hue) < Self.distance(hue, rhs.hue)
        }?.color ?? .blue
    }

    /// Оттенок токена на круге 0…360
    private static let legacyAnchors: [(color: Self, hue: Double)] = [
        (.green, 135), (.blue, 211), (.purple, 280), (.orange, 35), (.pink, 345)
    ]

    private static func distance(_ lhs: Double, _ rhs: Double) -> Double {
        let delta = abs(lhs - rhs)
        return min(delta, 360 - delta)
    }

    /// nil — не hex или цвет без оттенка
    private static func hue(ofHex hex: String) -> Double? {
        let digits = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard digits.count == 6, let value = Int(digits, radix: 16) else { return nil }

        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255

        let maxValue = max(red, green, blue)
        let delta = maxValue - min(red, green, blue)
        guard delta > 0.1 else { return nil }

        let hue: Double
        switch maxValue {
        case red: hue = ((green - blue) / delta).truncatingRemainder(dividingBy: 6)
        case green: hue = (blue - red) / delta + 2
        default: hue = (red - green) / delta + 4
        }
        return (hue * 60 + 360).truncatingRemainder(dividingBy: 360)
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
        static let overStripeStrong = "DS/overStripeStrong"
        static let overStripeSoft = "DS/overStripeSoft"
        static let scrim = "DS/scrim"
        static let dangerFill = "DS/dangerFill"
        static let onDanger = "DS/onDanger"
        static let grabber = "DS/grabber"
        static let noCategory = "DS/noCategory"
        static let inkDisabled = "DS/inkDisabled"
        static let onColorFill = "DS/onColorFill"
        static let emptyHatch = "DS/emptyHatch"
        static let accountRed = "DS/accountRed"
        static let accountTeal = "DS/accountTeal"
        static let accountLime = "DS/accountLime"
        static let accountCyan = "DS/accountCyan"
        static let accountIndigo = "DS/accountIndigo"

        static let all = [
            bg, surface, ink, ink2, line, accent, income, danger, onAccent,
            overStripeStrong, overStripeSoft, scrim, dangerFill, onDanger, grabber, noCategory,
            inkDisabled, onColorFill, emptyHatch, accountRed, accountTeal, accountLime, accountCyan, accountIndigo
        ]
    }
}

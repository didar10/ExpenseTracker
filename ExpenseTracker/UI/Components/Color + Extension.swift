//
//  Color + Extension.swift
//  ExpenseTracker
//
//  Created by Didar on 03.01.2026.
//

import SwiftUI

// MARK: - App Theme Colors

extension UIColor {
    /// Фон экрана: светлый — системный grouped, тёмный — тёмно-серый (#1C1C1E)
    static let appBackground = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
            : .systemGroupedBackground
    }

    /// Фон карточек/поверхностей: светлый — белый, тёмный — серый (#2C2C2E)
    static let appCardBackground = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
            : .systemBackground
    }

    /// Обводка карточки. В темной теме она заметно слабее: белый контур той же плотности,
    /// что и черный в светлой, забивает содержимое строки
    static let appCardBorder = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.18)
            : UIColor(white: 0, alpha: 0.7)
    }

    /// Жесткая тень карточки. Тень темнее поверхности в любой теме:
    /// светлая тень в темной теме читается как свечение, а не как объем
    static let appCardShadow = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 0, alpha: 0.45)
            : UIColor(white: 0, alpha: 0.7)
    }

    /// Темный край нижней карточки в карточке «стопкой»: почти черный, как жесткая тень
    static let appCardLedge = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 0, alpha: 0.6)
            : UIColor(white: 0, alpha: 0.9)
    }

    /// Мягкая тень под первичной кнопкой экрана
    static let appSoftShadow = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 0, alpha: 0.5)
            : UIColor(white: 0, alpha: 0.25)
    }
}

extension Color {
    static let appBackground = Color(uiColor: .appBackground)
    static let appCardBackground = Color(uiColor: .appCardBackground)
    static let appCardBorder = Color(uiColor: .appCardBorder)
    static let appCardShadow = Color(uiColor: .appCardShadow)
    static let appCardLedge = Color(uiColor: .appCardLedge)
    static let appSoftShadow = Color(uiColor: .appSoftShadow)
}

// MARK: - Color Utilities

extension Color {

    init(hex: String) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        let value = Int(hex, radix: 16) ?? 0x34C759

        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
    
    /// Создает Color из названия цвета (например: "blue", "green", "red")
    init(named colorName: String) {
        self = AppColorPalette.color(named: colorName)
    }

    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)

        return String(
            format: "#%02X%02X%02X",
            Int(r * 255),
            Int(g * 255),
            Int(b * 255)
        )
    }
}


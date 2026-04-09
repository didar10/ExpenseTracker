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
}

extension Color {
    static let appBackground = Color(uiColor: .appBackground)
    static let appCardBackground = Color(uiColor: .appCardBackground)
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
        switch colorName.lowercased() {
        case "blue": self = .blue
        case "green": self = .green
        case "orange": self = .orange
        case "red": self = .red
        case "purple": self = .purple
        case "pink": self = .pink
        case "yellow": self = .yellow
        case "teal": self = .teal
        case "indigo": self = .indigo
        case "brown": self = .brown
        case "cyan": self = .cyan
        case "mint": self = .mint
        default: self = .blue
        }
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


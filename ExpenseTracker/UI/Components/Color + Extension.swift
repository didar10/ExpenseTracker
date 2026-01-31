//
//  Color + Extension.swift
//  ExpenseTracker
//
//  Created by Didar on 03.01.2026.
//

import SwiftUI

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


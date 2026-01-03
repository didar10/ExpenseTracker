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


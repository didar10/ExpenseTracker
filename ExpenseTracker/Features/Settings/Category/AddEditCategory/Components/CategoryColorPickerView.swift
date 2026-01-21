//
//  CategoryColorPickerView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

/// Выбор цвета категории с preview
struct CategoryColorPickerView: View {
    @Binding var colorHex: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Preview текущего цвета
            Circle()
                .fill(Color(hex: colorHex))
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .strokeBorder(Color.black.opacity(0.1), lineWidth: 1)
                )
            
            // ColorPicker
            ColorPicker(
                "Выбрать цвет",
                selection: Binding(
                    get: { Color(hex: colorHex) },
                    set: { colorHex = $0.toHex() }
                )
            )
            .font(.system(size: 17))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview {
    CategoryColorPickerView(colorHex: .constant("#FF6B6B"))
        .padding()
        .background(Color(.systemGroupedBackground))
}

//
//  CategoryColorPickerView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

struct CategoryColorPickerView: View {

    // MARK: - Properties

    @Binding var colorHex: String

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: colorHex))
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .strokeBorder(AppColor.textPrimary.opacity(0.1), lineWidth: 1)
                )

            ColorPicker(
                AppString.selectColor,
                selection: Binding(
                    get: { Color(hex: colorHex) },
                    set: { colorHex = $0.toHex() }
                )
            )
            .font(.app(.body))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColor.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AppColor.textPrimary.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview {
    CategoryColorPickerView(colorHex: .constant("#FF6B6B"))
        .padding()
        .background(AppColor.background)
}

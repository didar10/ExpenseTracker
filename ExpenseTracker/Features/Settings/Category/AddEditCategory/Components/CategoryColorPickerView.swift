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
        HStack(spacing: AppSpacing.medium) {
            Circle()
                .fill(Color(hex: colorHex))
                .frame(width: AppSize.iconXLarge, height: AppSize.iconXLarge)
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
        .padding(AppSpacing.large)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColor.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .strokeBorder(AppColor.textPrimary.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview {
    CategoryColorPickerView(colorHex: .constant("#FF6B6B"))
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

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

    private let presetColors: [String] = [
        "#F5A623", "#E74C3C", "#E91E63", "#9C27B0", "#673AB7", "#3F51B5",
        "#2196F3", "#00BCD4", "#009688", "#4CAF50", "#8BC34A", "#9E9E9E"
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.small), count: 6)

    // MARK: - Body

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.medium) {
            ForEach(presetColors, id: \.self) { hex in
                colorSwatch(hex)
            }
        }
        .padding(AppSpacing.large)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColor.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .strokeBorder(AppColor.textPrimary.opacity(0.15), lineWidth: AppSpacing.hairline)
        )
    }
}

// MARK: - Subviews
private extension CategoryColorPickerView {

    func colorSwatch(_ hex: String) -> some View {
        let isSelected = colorHex.caseInsensitiveCompare(hex) == .orderedSame

        return ZStack {
            Circle()
                .fill(Color(hex: hex))
                .frame(width: AppSize.iconLarge, height: AppSize.iconLarge)

            if isSelected {
                AppImage.checkmark
                    .font(.system(size: AppSize.glyphLarge, weight: .bold))
                    .foregroundStyle(AppColor.textWhite)
            }
        }
        .overlay(
            Circle()
                .strokeBorder(AppColor.textPrimary.opacity(0.08), lineWidth: AppSpacing.hairline)
        )
        .frame(maxWidth: .infinity)
        .contentShape(Circle())
        .onTapGesture {
            colorHex = hex
        }
    }
}

#Preview {
    CategoryColorPickerView(colorHex: .constant("#F5A623"))
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

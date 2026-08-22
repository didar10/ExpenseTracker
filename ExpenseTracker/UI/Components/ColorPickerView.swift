//
//  ColorPickerView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI

struct ColorPickerView: View {

    // MARK: - Properties

    @Binding var selectedColor: String
    let onSelect: (String) -> Void

    private let colorNames: [String] = [
        "blue", "green", "orange", "red", "purple", "pink"
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.small), count: 6)

    // MARK: - Body

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.medium) {
            ForEach(colorNames, id: \.self) { name in
                colorSwatch(name)
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
private extension ColorPickerView {

    func colorSwatch(_ name: String) -> some View {
        let isSelected = selectedColor.caseInsensitiveCompare(name) == .orderedSame

        return ZStack {
            Circle()
                .fill(Color(named: name))
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
            selectedColor = name
            onSelect(name)
        }
    }
}

#Preview {
    ColorPickerView(selectedColor: .constant("blue"), onSelect: { _ in })
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

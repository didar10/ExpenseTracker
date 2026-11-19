//
//  ColorPickerView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI

/// Палитра выбора цвета: горизонтальный список кружков
struct ColorPickerView: View {

    // MARK: - Palette

    enum Palette {

        /// Системные цвета по имени: "blue", "green", ...
        case named
        /// Пресеты в формате hex: "#F5A623", ...
        case hex

        var values: [String] {
            switch self {
            case .named:
                return AppColorPalette.names

            case .hex:
                return [
                    "#F5A623", "#E74C3C", "#E91E63", "#9C27B0", "#673AB7", "#3F51B5",
                    "#2196F3", "#00BCD4", "#009688", "#4CAF50", "#8BC34A", "#9E9E9E"
                ]
            }
        }

        func color(for value: String) -> Color {
            switch self {
            case .named: return Color(named: value)
            case .hex: return Color(hex: value)
            }
        }
    }

    // MARK: - Properties

    @Binding var selectedColor: String
    var palette: Palette = .named
    var onSelect: (String) -> Void = { _ in }

    // MARK: - Body

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.medium) {
                ForEach(palette.values, id: \.self) { value in
                    colorSwatch(value)
                }
            }
            .padding(AppSpacing.large)
        }
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColor.fieldFill)
        )
    }
}

// MARK: - Subviews
private extension ColorPickerView {

    func colorSwatch(_ value: String) -> some View {
        let isSelected = selectedColor.caseInsensitiveCompare(value) == .orderedSame

        return ZStack {
            Circle()
                .fill(palette.color(for: value))
                .frame(width: AppSize.iconSmall, height: AppSize.iconSmall)

            if isSelected {
                AppImage.checkmark
                    .font(.system(size: AppSize.glyphSmall, weight: .bold))
                    .foregroundStyle(AppColor.textWhite)
            }
        }
        .overlay(
            Circle()
                .strokeBorder(AppColor.textPrimary.opacity(0.08), lineWidth: AppSpacing.hairline)
        )
        .contentShape(Circle())
        .onTapGesture {
            selectedColor = value
            onSelect(value)
        }
    }
}

#Preview {
    VStack(spacing: AppSpacing.large) {
        ColorPickerView(selectedColor: .constant("blue"))
        ColorPickerView(selectedColor: .constant("#F5A623"), palette: .hex)
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

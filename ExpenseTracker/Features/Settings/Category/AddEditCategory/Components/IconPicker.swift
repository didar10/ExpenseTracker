//
//  IconPicker.swift
//  ExpenseTracker
//
//  Created by Didar on 03.01.2026.
//

import SwiftUI

/// Палитра иконок категории: горизонтальная сетка из четырех рядов
struct IconPicker: View {

    // MARK: - Properties

    @Binding var selectedIcon: String
    let color: Color

    private let icons: [String] = [
        "cart", "cart.fill", "bag", "bag.fill",
        "basket", "creditcard", "creditcard.fill",
        "gift", "gift.fill", "tag",
        "fork.knife", "takeoutbag.and.cup.and.straw",
        "cup.and.saucer", "wineglass", "birthday.cake",
        "house", "house.fill", "sofa.fill",
        "lightbulb", "drop.fill", "flame.fill",
        "car", "car.fill", "bus", "tram",
        "airplane", "fuelpump", "bicycle",
        "heart", "heart.fill", "cross.case",
        "cross.case.fill", "pills.fill",
        "gamecontroller", "gamecontroller.fill",
        "tv", "music.note", "film",
        "graduationcap", "graduationcap.fill",
        "briefcase", "briefcase.fill",
        "book", "book.fill",
        "phone", "wifi", "antenna.radiowaves.left.and.right",
        "bolt.fill", "wrench.and.screwdriver",
        "pawprint", "leaf", "globe",
        "star", "star.fill"
    ]

    private let rows = Array(
        repeating: GridItem(.fixed(AppSize.iconLarge), spacing: AppSpacing.small),
        count: 4
    )

    // MARK: - Body

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, spacing: AppSpacing.small) {
                ForEach(icons, id: \.self) { icon in
                    iconCell(icon)
                }
            }
            .padding(AppSpacing.medium)
        }
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColor.fieldFill)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(AppString.selectIcon)
    }
}

// MARK: - Subviews
private extension IconPicker {

    func iconCell(_ icon: String) -> some View {
        let isSelected = selectedIcon == icon

        return Button {
            guard !isSelected else { return }

            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            selectedIcon = icon
        } label: {
            Image(systemName: icon)
                .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: AppSize.iconLarge, height: AppSize.iconLarge)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .fill(isSelected ? color : color.opacity(0.2))
                )
                // Выбранная плитка обводится: отличать её только по насыщенности
                // заливки на светлых цветах палитры тяжело
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .strokeBorder(
                            isSelected ? AppColor.textPrimary.opacity(0.35) : Color.clear,
                            lineWidth: AppSpacing.hairline
                        )
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(PressableScaleButtonStyle())
        .animation(.easeOut(duration: 0.15), value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    IconPicker(selectedIcon: .constant("cart"), color: Color(hex: "#F5A623"))
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

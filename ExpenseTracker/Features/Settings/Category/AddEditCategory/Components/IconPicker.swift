//
//  IconPicker.swift
//  ExpenseTracker
//
//  Created by Didar on 03.01.2026.
//

import SwiftUI

struct IconPicker: View {

    // MARK: - Properties

    @Binding var selectedIcon: String
    let colorHex: String

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

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.small), count: 6)

    // MARK: - Body

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.small) {
            ForEach(icons, id: \.self) { icon in
                iconCell(icon)
            }
        }
        .padding(AppSpacing.medium)
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
private extension IconPicker {

    func iconCell(_ icon: String) -> some View {
        let color = Color(hex: colorHex)
        let isSelected = selectedIcon == icon

        return Image(systemName: icon)
            .font(.system(size: AppSize.glyphLarge, weight: .semibold))
            .foregroundStyle(AppColor.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: AppSize.iconLarge)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .fill(isSelected ? color : color.opacity(0.2))
            )
            .contentShape(Rectangle())
            .onTapGesture {
                selectedIcon = icon
            }
    }
}

#Preview {
    IconPicker(selectedIcon: .constant("cart"), colorHex: "#F5A623")
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

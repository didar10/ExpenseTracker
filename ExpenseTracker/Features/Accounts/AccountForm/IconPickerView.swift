//
//  IconPickerView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI

struct IconPickerView: View {

    // MARK: - Properties

    @Binding var selectedIcon: String
    let color: Color
    let onSelect: (String) -> Void

    private let icons = [
        "creditcard.fill",
        "wallet.pass.fill",
        "banknote.fill",
        "tengesign.circle.fill",
        "building.columns.fill",
        "briefcase.fill"
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
private extension IconPickerView {

    func iconCell(_ icon: String) -> some View {
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
                onSelect(icon)
            }
    }
}

#Preview {
    IconPickerView(selectedIcon: .constant("creditcard.fill"), color: .blue, onSelect: { _ in })
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

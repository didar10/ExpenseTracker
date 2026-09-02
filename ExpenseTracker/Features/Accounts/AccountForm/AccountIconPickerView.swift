//
//  AccountIconPickerView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI

/// Иконки счета: наличные, карты, банк, накопления, переводы
struct AccountIconPickerView: View {

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
        "briefcase.fill",
        "dollarsign.circle.fill",
        "giftcard.fill",
        "person.2.fill",
        "house.fill",
        "car.fill",
        "airplane",
        "cart.fill",
        "heart.fill",
        "star.fill",
        "lock.fill",
        "bitcoinsign.circle.fill",
        "chart.line.uptrend.xyaxis"
    ]

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: AppSpacing.small),
        count: 6
    )

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
                .fill(AppColor.fieldFill)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(AppString.selectIcon)
    }
}

// MARK: - Subviews
private extension AccountIconPickerView {

    func iconCell(_ icon: String) -> some View {
        let isSelected = selectedIcon == icon

        return Button {
            guard !isSelected else { return }

            selectedIcon = icon
            onSelect(icon)
        } label: {
            Image(systemName: icon)
                .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: AppSize.iconLarge)
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
    AccountIconPickerView(
        selectedIcon: .constant("creditcard.fill"),
        color: Color(named: "blue"),
        onSelect: { _ in }
    )
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

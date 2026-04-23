//
//  CategoryIconPickerButtonView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

struct CategoryIconPickerButtonView: View {

    // MARK: - Properties

    let icon: String
    let colorHex: String
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.medium) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.medium)
                        .fill(Color(hex: colorHex).opacity(0.15))
                        .frame(width: AppSize.iconXLarge, height: AppSize.iconXLarge)

                    Image(systemName: icon)
                        .font(.system(size: AppSize.glyphXXLarge, weight: .semibold))
                        .foregroundStyle(Color(hex: colorHex))
                }

                AppText(AppString.selectIcon, style: .body)

                Spacer()

                AppImage.chevronRight
                    .font(.system(size: AppSize.glyphMedium, weight: .semibold))
                    .foregroundStyle(.tertiary)
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
        .buttonStyle(.plain)
    }
}

#Preview {
    CategoryIconPickerButtonView(icon: "cart.fill", colorHex: "#FF6B6B", action: {})
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

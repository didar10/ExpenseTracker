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
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: colorHex).opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color(hex: colorHex))
                }

                AppText(AppString.selectIcon, style: .body)

                Spacer()

                AppImage.chevronRight
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
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
        .buttonStyle(.plain)
    }
}

#Preview {
    CategoryIconPickerButtonView(icon: "cart.fill", colorHex: "#FF6B6B", action: {})
        .padding()
        .background(AppColor.background)
}

//
//  CategoryRowView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

struct CategoryRowView: View {

    // MARK: - Properties

    let category: Category
    let onDelete: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.small)
                    .fill(Color(hex: category.colorHex).opacity(0.15))
                    .frame(width: AppSize.iconLarge, height: AppSize.iconLarge)

                Image(systemName: category.icon)
                    .foregroundStyle(Color(hex: category.colorHex))
                    .font(.system(size: AppSize.glyphXLarge, weight: .semibold))
            }

            Text(category.name)
                .font(.app(.bodySmaller))
                .foregroundStyle(AppColor.textPrimary)

            Spacer()

            HStack(spacing: AppSpacing.large) {
                Button(action: onDelete) {
                    AppImage.trashFill
                        .font(.system(size: AppSize.glyphLarge))
                        .foregroundStyle(AppColor.expense.opacity(0.8))
                }
                .buttonStyle(.plain)

                AppImage.chevronRight
                    .font(.system(size: AppSize.glyphMedium, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, AppSpacing.small)
        .contentShape(Rectangle())
    }
}

#Preview {
    CategoryRowView(
        category: Category(name: "Продукты", icon: "cart.fill", colorHex: "#FF6B6B"),
        onDelete: {}
    )
    .padding(AppSpacing.large)
}

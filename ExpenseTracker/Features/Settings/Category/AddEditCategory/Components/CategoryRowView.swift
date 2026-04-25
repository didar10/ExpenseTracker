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
    let isEditing: Bool
    let onDelete: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            iconBadge

            AppText(category.name, style: .bodySmall)

            Spacer()

            trailingAccessories
        }
        .padding(.vertical, AppSpacing.small)
        .contentShape(Rectangle())
    }
}

// MARK: - Subviews
private extension CategoryRowView {

    var iconBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .fill(Color(hex: category.colorHex).opacity(0.2))
                .frame(width: AppSize.iconLarge, height: AppSize.iconLarge)

            Image(systemName: category.icon)
                .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
        }
    }

    @ViewBuilder
    var trailingAccessories: some View {
        if isEditing {
            HStack(spacing: AppSpacing.medium) {
                deleteButton
                dragHandle
            }
        } else {
            AppImage.chevronRight
                .font(.system(size: AppSize.glyphMedium, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
    }

    var deleteButton: some View {
        Button(action: onDelete) {
            AppImage.trash
                .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .fill(AppColor.expense.opacity(0.15))
                )
        }
        .buttonStyle(.plain)
    }

    var dragHandle: some View {
        VStack(spacing: AppSpacing.xxSmall) {
            ForEach(0..<2, id: \.self) { _ in
                HStack(spacing: AppSpacing.xSmall) {
                    Circle()
                        .fill(AppColor.textSecondary)
                        .frame(width: AppSpacing.xSmall, height: AppSpacing.xSmall)
                    Circle()
                        .fill(AppColor.textSecondary)
                        .frame(width: AppSpacing.xSmall, height: AppSpacing.xSmall)
                }
            }
        }
        .padding(.horizontal, AppSpacing.xSmall)
    }
}

#Preview {
    VStack {
        CategoryRowView(
            category: Category(name: "Продукты", icon: "cart.fill", colorHex: "#FF6B6B"),
            isEditing: false,
            onDelete: {}
        )
        CategoryRowView(
            category: Category(name: "Продукты", icon: "cart.fill", colorHex: "#FF6B6B"),
            isEditing: true,
            onDelete: {}
        )
    }
    .padding(AppSpacing.large)
}

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
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer(minLength: AppSpacing.small)

            trailingAccessories
        }
        .padding(.vertical, AppSpacing.small)
        .contentShape(Rectangle())
        .accessibilityElement(children: isEditing ? .contain : .combine)
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
                .foregroundStyle(Color(hex: category.colorHex))
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    var trailingAccessories: some View {
        if isEditing {
            deleteButton
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
                .foregroundStyle(AppColor.expense)
                .frame(width: AppSize.iconLarge, height: AppSize.iconLarge)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .fill(AppColor.expense.opacity(0.15))
                )
        }
        .buttonStyle(PressableScaleButtonStyle())
        .accessibilityLabel(AppString.delete)
    }
}

#Preview {
    VStack(spacing: 0) {
        CategoryRowView(
            category: Category(name: "Продукты", icon: "cart.fill", colorHex: "#FF6B6B"),
            isEditing: false,
            onDelete: {}
        )

        Divider()

        CategoryRowView(
            category: Category(name: "Кафе, рестораны и доставка еды", icon: "fork.knife", colorHex: "#F5A623"),
            isEditing: true,
            onDelete: {}
        )
    }
    .padding(AppSpacing.large)
    .card(cornerRadius: AppRadius.xLarge)
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

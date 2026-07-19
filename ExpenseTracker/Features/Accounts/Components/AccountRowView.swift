//
//  AccountRowView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.04.2026.
//

import SwiftUI

struct AccountRowView: View {

    // MARK: - Properties

    let account: Account
    let isEditing: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            iconBadge

            HStack(spacing: 4) {
                AppText(account.name, style: .bodySmall)

                if account.isDefault {
                    AppImage.starFill
                        .font(.system(size: 10))
                        .foregroundStyle(AppColor.highlight)
                }
            }

            Spacer()

            trailingAccessories
        }
        .padding(.vertical, AppSpacing.small)
        .contentShape(Rectangle())
    }
}

// MARK: - Subviews
private extension AccountRowView {

    var iconBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .fill(account.swiftUIColor.opacity(0.2))
                .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)

            Image(systemName: account.icon)
                .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
        }
    }

    @ViewBuilder
    var trailingAccessories: some View {
        if isEditing {
            HStack(spacing: AppSpacing.small) {
                editButton
                deleteButton
            }
        } else {
            Text(account.currentBalance.formatted(.currency(code: AppString.currencyCode)))
                .font(.app(.caption))
                .fontDesign(.rounded)
                .foregroundStyle(AppColor.textSecondary)
        }
    }

    var editButton: some View {
        Button(action: onEdit) {
            Image(systemName: "pencil")
                .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .fill(AppColor.accent.opacity(0.15))
                )
        }
        .buttonStyle(.plain)
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
}

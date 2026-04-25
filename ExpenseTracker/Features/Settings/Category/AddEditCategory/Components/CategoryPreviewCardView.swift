//
//  CategoryPreviewCardView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

struct CategoryPreviewCardView: View {

    // MARK: - Properties

    let name: String
    let icon: String
    let colorHex: String

    // MARK: - Body

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            AppText(
                AppString.preview.uppercased(),
                style: .microCaption,
                color: AppColor.textSecondary
            )
            .tracking(AppSpacing.hairline)

            previewPill
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xLarge)
        .padding(.horizontal, AppSpacing.large)
        .card(cornerRadius: AppRadius.xLarge)
    }
}

// MARK: - Subviews
private extension CategoryPreviewCardView {

    var previewPill: some View {
        HStack(spacing: AppSpacing.small) {
            ZStack {
                Circle()
                    .fill(AppColor.cardBackground.opacity(0.4))
                    .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)

                Image(systemName: icon)
                    .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
            }

            AppText(
                name.isEmpty ? AppString.categoryName : name,
                style: .bodySmall,
                color: AppColor.textPrimary
            )
        }
        .padding(.leading, AppSpacing.xSmall)
        .padding(.trailing, AppSpacing.xLarge)
        .padding(.vertical, AppSpacing.xSmall)
        .background(
            Capsule(style: .continuous)
                .fill(Color(hex: colorHex))
        )
    }
}

#Preview {
    VStack(spacing: AppSpacing.large) {
        CategoryPreviewCardView(name: "Продукты", icon: "cart.fill", colorHex: "#F5A623")
        CategoryPreviewCardView(name: "", icon: "cart.fill", colorHex: "#34C759")
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

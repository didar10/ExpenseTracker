//
//  CategoryPreviewCardView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

struct CategoryPreviewCardView: View {

    // MARK: - Properties

    @Binding var name: String
    let icon: String
    let colorHex: String

    // MARK: - Body

    var body: some View {
        previewPill
            .frame(maxWidth: .infinity)
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

            TextField(
                "",
                text: $name,
                prompt: Text(AppString.categoryName)
                    .font(.app(.bodySmall))
                    .foregroundColor(AppColor.textPrimary.opacity(0.6))
            )
            .font(.app(.bodySmall))
            .foregroundStyle(AppColor.textPrimary)
            .tint(AppColor.textPrimary)
        }
        .padding(.leading, AppSpacing.xSmall)
        .padding(.trailing, AppSpacing.xLarge)
        .padding(.vertical, AppSpacing.xSmall)
        .background(
            Capsule(style: .continuous)
                .fill(Color(hex: colorHex))
        )
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview {
    VStack(spacing: AppSpacing.large) {
        CategoryPreviewCardView(name: .constant("Продукты"), icon: "cart.fill", colorHex: "#F5A623")
        CategoryPreviewCardView(name: .constant(""), icon: "cart.fill", colorHex: "#34C759")
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

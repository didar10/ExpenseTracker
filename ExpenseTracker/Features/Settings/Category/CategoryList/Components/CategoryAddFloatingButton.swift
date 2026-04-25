//
//  CategoryAddFloatingButton.swift
//  ExpenseTracker
//
//  Created by Didar on 24.04.2026.
//

import SwiftUI

struct CategoryAddFloatingButton: View {

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.small) {
            AppImage.plus
                .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                .foregroundStyle(AppColor.textWhite)

            AppText(AppString.addNew, style: .bodySmall, color: AppColor.textWhite)
        }
        .padding(.horizontal, AppSpacing.xLarge)
        .padding(.vertical, AppSpacing.medium)
        .background(
            Capsule(style: .continuous)
                .fill(AppColor.textPrimary)
        )
        .shadow(
            color: AppColor.textPrimary.opacity(0.25),
            radius: AppSpacing.medium,
            y: AppSpacing.small
        )
    }
}

#Preview {
    ZStack(alignment: .bottomTrailing) {
        AppColor.background.ignoresSafeArea()
        CategoryAddFloatingButton()
            .padding(AppSpacing.large)
    }
}

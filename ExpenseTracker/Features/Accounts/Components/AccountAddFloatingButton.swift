//
//  AccountAddFloatingButton.swift
//  ExpenseTracker
//
//  Created by Didar on 25.04.2026.
//

import SwiftUI

struct AccountAddFloatingButton: View {

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.small) {
            Image(systemName: "plus")
                .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                .foregroundColor(Color(.systemBackground))

            AppText(AppString.addNew, style: .bodySmall, color: Color(.systemBackground))
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
        AccountAddFloatingButton()
            .padding(AppSpacing.large)
    }
}

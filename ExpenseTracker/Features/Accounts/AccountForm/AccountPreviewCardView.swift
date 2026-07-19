//
//  AccountPreviewCardView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI

struct AccountPreviewCardView: View {

    // MARK: - Properties

    @Binding var name: String
    let icon: String
    let colorName: String

    // MARK: - Body

    var body: some View {
        previewPill
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Subviews
private extension AccountPreviewCardView {

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
                prompt: Text(AppString.accountName)
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
                .fill(Color(named: colorName))
        )
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview {
    VStack(spacing: AppSpacing.large) {
        AccountPreviewCardView(name: .constant("Основной счёт"), icon: "creditcard.fill", colorName: "blue")
        AccountPreviewCardView(name: .constant(""), icon: "banknote.fill", colorName: "green")
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

//
//  LegalIntroCardView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.08.2026.
//

import SwiftUI

/// Вводная карточка для правовых экранов (политика конфиденциальности, условия использования)
struct LegalIntroCardView: View {

    // MARK: - Properties

    let icon: Image
    let accentColor: Color
    let title: String
    let subtitle: String
    var description: String?

    // MARK: - Body

    var body: some View {
        AppCardView {
            VStack(spacing: AppSpacing.large) {
                iconBadge

                VStack(spacing: AppSpacing.small) {
                    AppText(title, style: .section, alignment: .center)

                    AppText(
                        subtitle,
                        style: .caption,
                        color: AppColor.textSecondary,
                        alignment: .center
                    )
                }

                if let description {
                    AppText(
                        description,
                        style: .bodySmaller,
                        color: AppColor.textSecondary,
                        alignment: .center
                    )
                }
            }
            .padding(.vertical, AppSpacing.medium)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Subviews

    private var iconBadge: some View {
        ZStack {
            Circle()
                .fill(accentColor.opacity(0.15))
                .frame(width: AppSize.iconXXLarge, height: AppSize.iconXXLarge)

            icon
                .font(.system(size: AppSize.glyphXXLarge, weight: .semibold))
                .foregroundStyle(accentColor)
        }
    }
}

#Preview {
    LegalIntroCardView(
        icon: AppImage.handRaised,
        accentColor: AppColor.decorativePurple,
        title: AppString.privacyPolicy,
        subtitle: AppString.lastUpdated
    )
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

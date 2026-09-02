//
//  SettingsSectionView.swift
//  ExpenseTracker
//
//  Created by Didar on 02.09.2026.
//

import SwiftUI

/// Раздел настроек: заголовок и карточка со строками.
/// Содержимое обрезается по форме карточки, поэтому подсветка нажатия
/// не выходит за скругления у первой и последней строки
struct SettingsSectionView<Content: View>: View {

    // MARK: - Properties

    let title: String
    @ViewBuilder let content: Content

    // MARK: - Body

    var body: some View {
        VStack(spacing: AppSpacing.medium) {
            AppText(title, style: .sectionHeader, color: AppColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpacing.xSmall)

            VStack(spacing: .zero) {
                content
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
            .cardShadow(cornerRadius: AppRadius.card)
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    SettingsSectionView(title: AppString.information) {
        SettingsRowView(
            icon: AppImage.handRaised,
            iconColor: AppColor.decorativePurple,
            title: AppString.privacyPolicy
        ) {}

        SettingsRowDivider()

        SettingsRowView(
            icon: AppImage.questionmarkCircle,
            iconColor: AppColor.warning,
            title: AppString.helpAndSupport
        ) {}
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

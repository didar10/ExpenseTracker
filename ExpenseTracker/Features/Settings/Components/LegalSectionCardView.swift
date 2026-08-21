//
//  LegalSectionCardView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.08.2026.
//

import SwiftUI

/// Карточка одного раздела правового документа с порядковым номером
struct LegalSectionCardView: View {

    // MARK: - Properties

    let number: Int
    let accentColor: Color
    let title: String
    let content: String

    // MARK: - Body

    var body: some View {
        AppCardView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                HStack(spacing: AppSpacing.medium) {
                    numberBadge

                    AppText(title, style: .bodySmall)
                }

                AppText(content, style: .bodySmaller, color: AppColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Subviews

    private var numberBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .fill(accentColor.opacity(0.15))
                .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)

            AppText(String(number), style: .bodySmall, color: accentColor)
        }
    }
}

#Preview {
    LegalSectionCardView(
        number: 1,
        accentColor: AppColor.decorativePurple,
        title: AppString.privacySection1Title,
        content: AppString.privacySection1Content
    )
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

//
//  CategoryFormSectionView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

struct CategoryFormSectionView<Content: View>: View {

    // MARK: - Properties

    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            AppText(title, style: .bodySmall, color: AppColor.textSecondary)
                .padding(.horizontal, AppSpacing.xSmall)

            content
        }
    }
}

#Preview {
    CategoryFormSectionView(title: AppString.name) {
        TextField(AppString.enterName, text: .constant(""))
            .padding(AppSpacing.large)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.card)
                    .fill(AppColor.cardBackground)
            )
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

//
//  EmptyCategoriesView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

struct EmptyCategoriesView: View {

    // MARK: - Properties

    var title: String = AppString.noCategories
    var hint: String = AppString.addCategoryHint
    /// Задано, когда категорию можно создать прямо из пустого состояния
    var onCreateTap: (() -> Void)?

    // MARK: - Body

    var body: some View {
        AppCardView {
            VStack(spacing: AppSpacing.large) {
                AppImage.folder
                    .font(.system(size: AppSize.glyphEmptyState))
                    .foregroundStyle(.tertiary)
                    .symbolRenderingMode(.hierarchical)

                VStack(spacing: AppSpacing.small) {
                    AppText(title, style: .section)

                    AppText(hint, style: .bodySmaller, color: AppColor.textSecondary, alignment: .center)
                }

                if let onCreateTap {
                    PillActionButton(title: AppString.createCategory, action: onCreateTap)
                        .padding(.top, AppSpacing.small)
                }
            }
            .padding(.vertical, AppSpacing.xxLarge)
            .frame(maxWidth: .infinity)
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview("Нет категорий") {
    EmptyCategoriesView(onCreateTap: {})
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

#Preview("Все использованы") {
    EmptyCategoriesView(title: AppString.allCategoriesUsed, hint: AppString.allCategoriesUsedHint)
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

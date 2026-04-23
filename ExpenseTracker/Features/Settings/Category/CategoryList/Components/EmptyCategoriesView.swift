//
//  EmptyCategoriesView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

struct EmptyCategoriesView: View {

    // MARK: - Body

    var body: some View {
        CategoriesCardView {
            VStack(spacing: AppSpacing.large) {
                AppImage.folder
                    .font(.system(size: AppSize.iconXXLarge))
                    .foregroundStyle(.tertiary)
                    .symbolRenderingMode(.hierarchical)

                VStack(spacing: AppSpacing.small) {
                    AppText(AppString.noCategories, style: .section)

                    AppText(AppString.addCategoryHint, style: .bodySmaller, color: AppColor.textSecondary, alignment: .center)
                }
            }
            .padding(.vertical, AppSpacing.xxLarge)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    EmptyCategoriesView()
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

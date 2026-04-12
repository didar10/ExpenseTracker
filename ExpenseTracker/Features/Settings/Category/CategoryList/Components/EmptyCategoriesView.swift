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
            VStack(spacing: 16) {
                AppImage.folder
                    .font(.system(size: 56))
                    .foregroundStyle(.tertiary)
                    .symbolRenderingMode(.hierarchical)

                VStack(spacing: 8) {
                    AppText(AppString.noCategories, style: .section)

                    AppText(AppString.addCategoryHint, style: .bodySmaller, color: AppColor.textSecondary, alignment: .center)
                }
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    EmptyCategoriesView()
        .padding()
        .background(AppColor.background)
}

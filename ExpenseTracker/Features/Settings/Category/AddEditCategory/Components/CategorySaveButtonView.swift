//
//  CategorySaveButtonView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

struct CategorySaveButtonView: View {

    // MARK: - Properties

    let title: String
    let isEnabled: Bool
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            AppText(
                title,
                style: .section,
                color: isEnabled ? AppColor.textWhite : AppColor.textSecondary
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.large)
            .background(
                Capsule(style: .continuous)
                    .fill(isEnabled ? AppColor.textPrimary : AppColor.secondaryBackground)
            )
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: AppSpacing.large) {
        CategorySaveButtonView(title: AppString.createCategory, isEnabled: true, action: {})
        CategorySaveButtonView(title: AppString.enterName, isEnabled: false, action: {})
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

//
//  CategoryEditToggleButton.swift
//  ExpenseTracker
//
//  Created by Didar on 24.04.2026.
//

import SwiftUI

struct CategoryEditToggleButton: View {

    // MARK: - Properties

    let isEditing: Bool
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            AppText(
                isEditing ? AppString.done : AppString.edit,
                style: .bodySmall,
                color: isEditing ? AppColor.textWhite : AppColor.textPrimary
            )
            .padding(.horizontal, AppSpacing.large)
            .padding(.vertical, AppSpacing.small)
            .background(
                Capsule(style: .continuous)
                    .fill(isEditing ? AppColor.textPrimary : AppColor.cardBackground)
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(
                        isEditing ? Color.clear : AppColor.textPrimary,
                        lineWidth: AppSpacing.hairline
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: AppSpacing.large) {
        CategoryEditToggleButton(isEditing: false, action: {})
        CategoryEditToggleButton(isEditing: true, action: {})
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

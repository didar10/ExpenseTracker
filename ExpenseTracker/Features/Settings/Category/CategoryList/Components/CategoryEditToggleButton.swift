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
            ToolbarIconButtonLabel(
                icon: isEditing ? "checkmark" : "pencil",
                isOutlined: true
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

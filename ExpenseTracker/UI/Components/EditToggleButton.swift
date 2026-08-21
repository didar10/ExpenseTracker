//
//  EditToggleButton.swift
//  ExpenseTracker
//
//  Created by Didar on 22.08.2026.
//

import SwiftUI

/// Кнопка переключения режима редактирования списка
struct EditToggleButton: View {

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
        EditToggleButton(isEditing: false, action: {})
        EditToggleButton(isEditing: true, action: {})
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

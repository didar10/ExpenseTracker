//
//  PrimaryActionButton.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

/// Главное действие экрана: широкая капсула во всю ширину контента.
/// Неактивная кнопка остается видимой, но теряет контраст
struct PrimaryActionButton: View {

    // MARK: - Properties

    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            AppText(
                title,
                style: .bodySmall,
                color: isEnabled ? AppColor.background : AppColor.textSecondary,
                alignment: .center
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.large)
            .background(
                Capsule(style: .continuous)
                    .fill(isEnabled ? AppColor.textPrimary : AppColor.subtleFill)
            )
        }
        .disabled(!isEnabled)
        .buttonStyle(PressableScaleButtonStyle())
    }
}

#Preview {
    VStack(spacing: AppSpacing.large) {
        PrimaryActionButton(title: AppString.createCategory, action: {})
        PrimaryActionButton(title: AppString.enterName, isEnabled: false, action: {})
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

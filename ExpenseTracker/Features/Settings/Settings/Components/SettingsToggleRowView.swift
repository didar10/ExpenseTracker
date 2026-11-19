//
//  SettingsToggleRowView.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import SwiftUI

/// Строка настроек с переключателем: оформлена как SettingsRowView, но без шеврона
struct SettingsToggleRowView: View {

    // MARK: - Properties

    let icon: Image
    let iconColor: Color
    let title: String
    @Binding var isOn: Bool

    // MARK: - Body

    var body: some View {
        Toggle(isOn: $isOn.animation(.snappy(duration: Constants.toggleDuration))) {
            HStack(spacing: AppSpacing.large) {
                SettingsIconBadge(icon: icon, color: iconColor)

                AppText(title, style: .bodySmaller)
                    .lineLimit(2)
            }
        }
        .toggleStyle(.pill)
        .sensoryFeedback(.selection, trigger: isOn)
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.medium)
        .frame(minHeight: AppSize.iconXLarge)
    }
}

// MARK: - Constants

private extension SettingsToggleRowView {

    enum Constants {
        static let toggleDuration: Double = 0.2
    }
}

#Preview {
    SettingsToggleRowView(
        icon: AppImage.dailyLimit,
        iconColor: AppColor.income,
        title: AppString.showLimitOnDashboard,
        isOn: .constant(true)
    )
    .layeredCard()
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

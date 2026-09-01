//
//  PillActionButton.swift
//  ExpenseTracker
//
//  Created by Didar on 01.09.2026.
//

import SwiftUI

/// Действие в пустом состоянии: тёмная капсула с одной подписью
struct PillActionButton: View {

    // MARK: - Properties

    let title: String
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            AppText(title, style: .bodySmall)
                .color(AppColor.background)
                .padding(.horizontal, AppSpacing.xLarge)
                .padding(.vertical, AppSpacing.medium)
                .background {
                    Capsule().fill(AppColor.textPrimary)
                }
        }
        .buttonStyle(PressableScaleButtonStyle())
    }
}

#Preview {
    PillActionButton(title: AppString.periodAllTime) {}
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

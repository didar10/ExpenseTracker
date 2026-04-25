//
//  ToolbarIconButton.swift
//  ExpenseTracker
//
//  Created by Didar on 14.02.2026.
//

import SwiftUI

struct ToolbarIconButtonLabel: View {
    let icon: String
    var isEnabled: Bool = true
    var isOutlined: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.appCardBackground)
                .opacity(isEnabled ? 1 : 0.5)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .strokeBorder(
                            isOutlined ? AppColor.textPrimary : Color.clear,
                            lineWidth: AppSpacing.hairline
                        )
                )
                .shadow(
                    color: isOutlined ? Color.clear : Color.primary.opacity(isEnabled ? 0.1 : 0.05),
                    radius: 3,
                    x: 0,
                    y: 2
                )

            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isEnabled ? .primary : .secondary)
        }
    }
}

struct ToolbarIconButton: View {
    let icon: String
    var isEnabled: Bool = true
    var isOutlined: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ToolbarIconButtonLabel(icon: icon, isEnabled: isEnabled, isOutlined: isOutlined)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

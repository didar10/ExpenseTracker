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

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(uiColor: .systemBackground))
                .opacity(isEnabled ? 1 : 0.5)
                .frame(width: 40, height: 40)
                .shadow(
                    color: Color.primary.opacity(isEnabled ? 0.1 : 0.05),
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
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ToolbarIconButtonLabel(icon: icon, isEnabled: isEnabled)
        }
        .disabled(!isEnabled)
    }
}

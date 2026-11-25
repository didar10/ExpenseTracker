//
//  IconButton.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Квадратная кнопка-иконка 44×44: «+» в заголовке, «×» на листе. Без тени
struct IconButton: View {

    // MARK: - Properties

    let icon: Image
    /// Обязательна: у кнопки нет текста, VoiceOver читает только эту подпись
    let accessibilityLabel: String
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            icon
                .font(.system(size: DS.Size.iconXL, weight: .semibold))
                .frame(width: DS.Size.control, height: DS.Size.control)
        }
        .buttonStyle(.outlineClick)
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Previews

#if DEBUG
private struct IconButtonGallery: View {

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Обычная") {
                HStack(spacing: DS.Spacing.md) {
                    IconButton(icon: Image(systemName: "plus"), accessibilityLabel: "Новый бюджет") {}
                    IconButton(icon: Image(systemName: "xmark"), accessibilityLabel: "Закрыть") {}
                }
            }
            DSPreviewCase("Нажата") {
                OutlineClickBody(shape: .bordered(radius: DS.Radius.control), fill: DS.Color.surface, isPressed: true) {
                    Image(systemName: "plus")
                        .font(.system(size: DS.Size.iconXL, weight: .semibold))
                        .frame(width: DS.Size.control, height: DS.Size.control)
                }
            }
            DSPreviewCase("Disabled") {
                IconButton(icon: Image(systemName: "plus"), accessibilityLabel: "Новый бюджет") {}
                    .disabled(true)
            }
        }
    }
}

#Preview("Светлая") {
    IconButtonGallery()
}

#Preview("Темная") {
    IconButtonGallery()
        .preferredColorScheme(.dark)
}
#endif

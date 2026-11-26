//
//  IconButton.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Квадратная кнопка-иконка 44×44: «+» в заголовке, «×» на листе.
/// Обычно без тени — «щелчок обводки»; с тенью — «вдавливание в тень»
struct IconButton: View {

    // MARK: - Types

    enum Elevation {
        /// Обводка без тени: «×», «‹»
        case flat
        /// Жесткая тень: «+» в шапке бюджетов — `Budgets.html` (.rbtn)
        case raised
    }

    // MARK: - Properties

    let icon: Image
    /// Обязательна: у кнопки нет текста, VoiceOver читает только эту подпись
    let accessibilityLabel: String
    var elevation: Elevation = .flat
    let action: () -> Void

    // MARK: - Init

    init(icon: Image, accessibilityLabel: String, elevation: Elevation = .flat, action: @escaping () -> Void) {
        self.icon = icon
        self.accessibilityLabel = accessibilityLabel
        self.elevation = elevation
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        switch elevation {
        case .flat:
            button.buttonStyle(.outlineClick)
        case .raised:
            button
                .buttonStyle(.pressIntoShadow(.secondary))
                .frame(width: DS.Size.control, height: DS.Size.control)
        }
    }

    private var button: some View {
        Button(action: action) {
            icon
                .font(.system(size: DS.Size.iconXL, weight: .semibold))
                .frame(width: DS.Size.control, height: DS.Size.control)
        }
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
            DSPreviewCase("С тенью · «+» бюджетов") {
                IconButton(icon: Image(systemName: "plus"), accessibilityLabel: "Новый бюджет", elevation: .raised) {}
            }
            DSPreviewCase("С тенью · нажата") {
                PressIntoShadowBody(variant: .secondary, radius: DS.Radius.control, isPressed: true) {
                    Image(systemName: "plus")
                        .font(.system(size: DS.Size.iconXL, weight: .semibold))
                        .frame(width: DS.Size.control, height: DS.Size.control)
                }
                .frame(width: DS.Size.control)
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

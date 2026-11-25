//
//  PrimaryButton.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Главная кнопка экрана высотой 56: «Сохранить», «Создать счет», «Удалить операцию».
/// Единственный, наряду с «+» таббара и ⇄ перевода, компонент с жесткой тенью
struct PrimaryButton: View {

    // MARK: - Properties

    let title: String
    var icon: Image?
    var variant: PressIntoShadowStyle.Variant = .primary
    let action: () -> Void

    // MARK: - Init

    init(
        title: String,
        icon: Image? = nil,
        variant: PressIntoShadowStyle.Variant = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.sm) {
                icon?
                    .font(.system(size: DS.Size.iconL, weight: .bold))
                    .accessibilityHidden(true)

                Text(title)
                    .font(DS.Font.button)
                    .lineLimit(1)
                    .minimumScaleFactor(Constants.minimumScale)
            }
            .padding(.horizontal, DS.Spacing.lg)
            .frame(minHeight: DS.Size.primaryButton)
        }
        .buttonStyle(PressIntoShadowStyle(variant: variant))
    }
}

// MARK: - Constants

private extension PrimaryButton {

    enum Constants {
        /// Длинное название на узком экране ужимается, а не переносится
        static let minimumScale: CGFloat = 0.8
    }
}

// MARK: - Previews

#if DEBUG
private struct PrimaryButtonGallery: View {

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Primary") {
                PrimaryButton(title: "Сохранить") {}
            }
            DSPreviewCase("Primary с иконкой") {
                PrimaryButton(title: "Добавить расход", icon: Image(systemName: "plus")) {}
            }
            DSPreviewCase("Primary · нажата") {
                PressIntoShadowBody(variant: .primary, radius: DS.Radius.control, isPressed: true) {
                    Text("Сохранить")
                        .font(DS.Font.button)
                        .frame(minHeight: DS.Size.primaryButton)
                }
            }
            DSPreviewCase("Danger") {
                PrimaryButton(title: "Удалить операцию", variant: .danger) {}
            }
            DSPreviewCase("Danger · нажата") {
                PressIntoShadowBody(variant: .danger, radius: DS.Radius.control, isPressed: true) {
                    Text("Удалить операцию")
                        .font(DS.Font.button)
                        .frame(minHeight: DS.Size.primaryButton)
                }
            }
            DSPreviewCase("Disabled") {
                PrimaryButton(title: "Введите сумму") {}
                    .disabled(true)
            }
        }
    }
}

#Preview("Светлая") {
    PrimaryButtonGallery()
}

#Preview("Темная") {
    PrimaryButtonGallery()
        .preferredColorScheme(.dark)
}
#endif

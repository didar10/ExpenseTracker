//
//  AddFloatingButton.swift
//  ExpenseTracker
//
//  Created by Didar on 02.09.2026.
//

import SwiftUI

/// Плавающая кнопка добавления над списком: тёмная капсула в правом нижнем углу.
/// Подпись задаётся экраном, потому что род слова разный: «Новая» категория, «Новый» счет
struct AddFloatingButton: View {

    // MARK: - Properties

    let title: String
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            HStack(spacing: AppSpacing.small) {
                AppImage.plus
                    .font(.system(size: AppSize.glyphLarge, weight: .semibold))

                AppText(title, style: .bodySmall, color: AppColor.background)
            }
            .foregroundStyle(AppColor.background)
            .padding(.horizontal, AppSpacing.xLarge)
            .padding(.vertical, AppSpacing.medium)
            .background(
                Capsule(style: .continuous)
                    .fill(AppColor.textPrimary)
            )
            // Тень всегда затемняет: цвет текста в темной теме дал бы светящийся ореол
            .shadow(
                color: Color.black.opacity(0.2),
                radius: AppSpacing.medium,
                y: AppSpacing.small
            )
        }
        .buttonStyle(PressableScaleButtonStyle())
    }
}

#Preview {
    ZStack(alignment: .bottomTrailing) {
        AppColor.background.ignoresSafeArea()

        AddFloatingButton(title: AppString.newAccountShort) {}
            .padding(AppSpacing.large)
    }
}

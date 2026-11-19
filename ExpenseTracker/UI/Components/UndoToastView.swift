//
//  UndoToastView.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import SwiftUI

/// Тост с кнопкой «Отменить»: заменяет окно подтверждения перед необратимым действием.
/// Инвертированные цвета выделяют его поверх любого контента в обеих темах
struct UndoToastView: View {

    // MARK: - Properties

    let message: String
    let onUndo: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            AppText(message, style: .caption, color: AppColor.background)
                .lineLimit(1)

            Spacer(minLength: AppSpacing.small)

            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onUndo()
            } label: {
                HStack(spacing: AppSpacing.xSmall) {
                    AppImage.undo
                        .font(.system(size: AppSize.glyphSmall, weight: .semibold))

                    AppText(AppString.undo, style: .captionMedium, color: AppColor.background)
                }
                .foregroundStyle(AppColor.background)
                .padding(.horizontal, AppSpacing.medium)
                .padding(.vertical, AppSpacing.smaller)
                .background {
                    Capsule().fill(AppColor.background.opacity(Constants.undoFillOpacity))
                }
            }
            .buttonStyle(PressableScaleButtonStyle())
        }
        .padding(.leading, AppSpacing.large)
        .padding(.trailing, AppSpacing.small)
        .padding(.vertical, AppSpacing.small)
        .background {
            Capsule()
                .fill(AppColor.textPrimary)
                .shadow(color: AppColor.softShadow, radius: AppSize.shadowRadius, y: AppSize.shadowOffsetY)
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Constants

private extension UndoToastView {

    enum Constants {
        static let undoFillOpacity: Double = 0.15
    }
}

#Preview {
    UndoToastView(message: "Операция удалена", onUndo: {})
        .padding(AppSpacing.large)
}

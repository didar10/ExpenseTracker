//
//  SettingsRowView.swift
//  ExpenseTracker
//
//  Created by Didar on 02.09.2026.
//

import SwiftUI

/// Строка настроек: цветная иконка, название и шеврон.
/// Нажатие подсвечивается фоном, а не масштабом: строка стоит в общей карточке
struct SettingsRowView: View {

    // MARK: - Properties

    let icon: Image
    let iconColor: Color
    let title: String
    var titleColor: Color = AppColor.textPrimary
    var showsChevron: Bool = true
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            label
        }
        // Углы скругляет карточка раздела, поэтому подсветка строки прямоугольная
        .buttonStyle(HighlightRowButtonStyle(cornerRadius: .zero))
    }
}

// MARK: - Subviews
private extension SettingsRowView {

    var label: some View {
        HStack(spacing: AppSpacing.large) {
            iconBadge

            AppText(title, style: .bodySmaller, color: titleColor)
                .lineLimit(2)

            Spacer(minLength: AppSpacing.small)

            if showsChevron {
                AppImage.chevronRight
                    .font(.system(size: AppSize.glyphMedium, weight: .semibold))
                    .foregroundStyle(AppColor.textTertiary)
            }
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.medium)
        .frame(minHeight: AppSize.iconXLarge)
        .contentShape(Rectangle())
    }

    var iconBadge: some View {
        ZStack {
            Circle()
                .fill(iconColor.opacity(0.15))
                .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)

            icon
                .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                .foregroundStyle(iconColor)
        }
        .circleShadow()
        .accessibilityHidden(true)
    }
}

// MARK: - Divider

/// Разделитель строк настроек: начинается там же, где название строки
struct SettingsRowDivider: View {

    var body: some View {
        Divider()
            .padding(.leading, AppSpacing.large + AppSize.iconMedium + AppSpacing.large)
    }
}

#Preview {
    VStack(spacing: .zero) {
        SettingsRowView(
            icon: AppImage.categoriesGrid,
            iconColor: AppColor.accent,
            title: AppString.categories
        ) {}

        SettingsRowDivider()

        SettingsRowView(
            icon: AppImage.trashFill,
            iconColor: AppColor.expense,
            title: AppString.deleteAllData,
            titleColor: AppColor.expense,
            showsChevron: false
        ) {}
    }
    .cardShadow(cornerRadius: AppRadius.card)
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

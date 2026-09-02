//
//  FAQItemView.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI

/// Вопрос из справки: карточка раскрывается по нажатию в любом месте строки
struct FAQItemView: View {

    // MARK: - Properties

    let item: FAQItem
    let isExpanded: Bool
    let onTap: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                question
            }
            .buttonStyle(HighlightRowButtonStyle(cornerRadius: AppRadius.medium))

            if isExpanded {
                Divider()
                    .padding(.vertical, AppSpacing.medium)

                AppText(item.answer, style: .bodySmaller, color: AppColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
        }
        .padding(AppSpacing.large)
        .card(cornerRadius: AppRadius.xLarge)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(isExpanded ? AppString.collapseAnswer : AppString.expandAnswer)
    }
}

// MARK: - Subviews
private extension FAQItemView {

    var question: some View {
        HStack(spacing: AppSpacing.medium) {
            AppText(item.question, style: .bodySmall)
                .frame(maxWidth: .infinity, alignment: .leading)

            expandIcon
        }
        .contentShape(Rectangle())
    }

    var expandIcon: some View {
        AppImage.chevronDown
            .font(.system(size: AppSize.glyphMedium, weight: .semibold))
            .foregroundStyle(AppColor.textSecondary)
            // Одна и та же иконка поворачивается, а не подменяется другой:
            // раскрытие читается как продолжение нажатия
            .rotationEffect(.degrees(isExpanded ? 180 : 0))
            .frame(width: AppSize.iconSmall, height: AppSize.iconSmall)
            .background(
                Circle()
                    .fill(AppColor.subtleFill)
            )
    }
}

#Preview {
    VStack(spacing: AppSpacing.medium) {
        FAQItemView(item: FAQItem.all[0], isExpanded: false, onTap: {})
        FAQItemView(item: FAQItem.all[1], isExpanded: true, onTap: {})
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

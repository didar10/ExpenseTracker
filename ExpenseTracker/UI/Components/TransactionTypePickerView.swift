//
//  TransactionTypePickerView.swift
//  ExpenseTracker
//
//  Created by Didar on 23.01.2026.
//

import SwiftUI

struct TransactionTypePickerView: View {

    /// Подложка переключателя
    enum Style {
        /// Залитая капсула
        case filled
        /// Капсула с обводкой и второй капсулой снизу, как layeredCard у карточек
        case layered
    }

    // MARK: - Properties

    @Binding var selectedType: TransactionType
    var backgroundColor: Color = AppColor.secondaryBackground
    var style: Style = .filled

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.smaller) {
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedType = .expense
                }
            } label: {
                HStack(spacing: AppSpacing.smaller) {
                    AppImage.expenseDirection
                        .font(.system(size: AppSize.glyphMedium, weight: .semibold))
                        .foregroundStyle(AppColor.warning)
                    if selectedType == .expense {
                        AppText(AppString.expense, style: .captionMedium, color: AppColor.warning)
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                    }
                }
                .padding(.horizontal, AppSpacing.mediumSmall)
                .padding(.vertical, AppSpacing.small)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                        .fill(selectedType == .expense ? AppColor.warning.opacity(0.15) : .clear)
                )
            }
            .buttonStyle(.plain)
            // Невыбранная половина показывает только иконку: без подписи
            // VoiceOver прочитал бы имя SF Symbol
            .accessibilityLabel(AppString.expense)
            .accessibilityAddTraits(selectedType == .expense ? [.isButton, .isSelected] : .isButton)

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedType = .income
                }
            } label: {
                HStack(spacing: AppSpacing.smaller) {
                    AppImage.incomeDirection
                        .font(.system(size: AppSize.glyphMedium, weight: .semibold))
                        .foregroundStyle(AppColor.income)
                    if selectedType == .income {
                        AppText(AppString.income, style: .captionMedium, color: AppColor.income)
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                }
                .padding(.horizontal, AppSpacing.mediumSmall)
                .padding(.vertical, AppSpacing.small)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                        .fill(selectedType == .income ? AppColor.income.opacity(0.15) : .clear)
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(AppString.income)
            .accessibilityAddTraits(selectedType == .income ? [.isButton, .isSelected] : .isButton)
        }
        .padding(AppSpacing.smaller)
        .modifier(PickerBackground(style: style, color: backgroundColor))
    }
}

// MARK: - Background

private extension TransactionTypePickerView {

    struct PickerBackground: ViewModifier {
        let style: Style
        let color: Color

        func body(content: Content) -> some View {
            switch style {
            case .filled:
                content.background(Capsule().fill(color))
            case .layered:
                content.layeredCard(cornerRadius: AppRadius.capsule)
            }
        }
    }
}

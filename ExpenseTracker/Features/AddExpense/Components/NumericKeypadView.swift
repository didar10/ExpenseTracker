//
//  NumericKeypadView.swift
//  ExpenseTracker
//
//  Created by Didar on 05.01.2026.
//

import SwiftUI

struct NumericKeypadView: View {

    // MARK: - Types

    enum Key: Hashable {
        case number(String)
        case decimal
        case delete
    }

    // MARK: - Properties

    let isEnterEnabled: Bool
    let enterTitle: String
    /// Причина, по которой сохранение недоступно: показывается вместо названия кнопки
    let disabledHint: String?
    let onKeyTap: (Key) -> Void
    let onClearTap: () -> Void
    let onEnterTap: () -> Void

    private let rows: [[Key]] = [
        [.number("1"), .number("2"), .number("3")],
        [.number("4"), .number("5"), .number("6")],
        [.number("7"), .number("8"), .number("9")],
        [.decimal, .number("0"), .delete]
    ]

    // MARK: - Body

    var body: some View {
        VStack(spacing: AppSpacing.small) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: AppSpacing.small) {
                    ForEach(row, id: \.self) { key in
                        keyButton(key)
                    }
                }
            }

            enterButton
        }
    }
}

// MARK: - Subviews
private extension NumericKeypadView {

    @ViewBuilder
    func keyButton(_ key: Key) -> some View {
        let button = Button {
            onKeyTap(key)
        } label: {
            keyLabel(key)
        }
        .buttonStyle(KeypadKeyButtonStyle())
        .accessibilityLabel(accessibilityLabel(for: key))
        .accessibilityHint(accessibilityHint(for: key))

        if case .delete = key {
            // Долгое нажатие очищает всю сумму — быстрее, чем стирать по цифре
            button.simultaneousGesture(
                LongPressGesture(minimumDuration: 0.4).onEnded { _ in onClearTap() }
            )
        } else {
            button
        }
    }

    @ViewBuilder
    func keyLabel(_ key: Key) -> some View {
        switch key {
        case .number(let value):
            Text(value)
                .font(.system(size: AppSize.keypadDigit, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(AppColor.textPrimary)

        case .decimal:
            Text(AppString.amountDecimalSeparator)
                .font(.system(size: AppSize.keypadDigit, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColor.textPrimary)

        case .delete:
            AppImage.deleteBackward
                .font(.system(size: AppSize.glyphXXLarge, weight: .semibold))
                .foregroundStyle(AppColor.expense)
                .symbolRenderingMode(.hierarchical)
        }
    }

    func accessibilityLabel(for key: Key) -> String {
        switch key {
        case .number(let value): value
        case .decimal: AppString.accessibilityDecimalSeparator
        case .delete: AppString.accessibilityDeleteDigit
        }
    }

    func accessibilityHint(for key: Key) -> String {
        if case .delete = key {
            return AppString.accessibilityClearAmount
        }

        return ""
    }

    var enterButton: some View {
        Button {
            if isEnterEnabled {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                onEnterTap()
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            }
        } label: {
            Text(isEnterEnabled ? enterTitle : (disabledHint ?? enterTitle))
                .font(.app(.bodySmall))
                .foregroundStyle(AppColor.background)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, AppSpacing.large)
                .frame(maxWidth: .infinity)
                .frame(height: AppSize.primaryButton)
                .background {
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .fill(AppColor.textPrimary)
                        .opacity(isEnterEnabled ? 1 : 0.35)
                        .shadow(
                            color: AppColor.textPrimary.opacity(isEnterEnabled ? 0.25 : 0),
                            radius: AppSize.shadowRadius,
                            y: AppSize.shadowOffsetY
                        )
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(PressableScaleButtonStyle())
        .padding(.top, AppSpacing.medium)
        .animation(.snappy(duration: 0.25), value: isEnterEnabled)
    }
}

// MARK: - Button Styles

/// Клавиша реагирует на нажатие пальца, а не на таймер после отпускания
private struct KeypadKeyButtonStyle: ButtonStyle {

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: AppSize.keypadKey)
            .background {
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .fill(AppColor.subtleFill)
                    .opacity(configuration.isPressed ? 1 : 0)
            }
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
            .contentShape(Rectangle())
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

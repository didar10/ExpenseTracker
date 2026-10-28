//
//  PillToggleStyle.swift
//  ExpenseTracker
//
//  Created by Didar on 27.10.2026.
//

import SwiftUI

/// Переключатель-капсула с подписью: включенный — темный, «Вкл» слева и кружок справа;
/// выключенный — светлый, кружок слева и «Выкл» справа.
/// Переключается нажатием на всю строку, а не только на капсулу
struct PillToggleStyle: ToggleStyle {

    // MARK: - Body

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: .zero) {
                configuration.label

                Spacer(minLength: AppSpacing.medium)

                pill(isOn: configuration.isOn)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isToggle)
        .accessibilityValue(configuration.isOn ? AppString.toggleOn : AppString.toggleOff)
    }
}

// MARK: - Subviews

private extension PillToggleStyle {

    func pill(isOn: Bool) -> some View {
        HStack(spacing: AppSpacing.xSmall) {
            if isOn {
                label(isOn: isOn)
                knob
            } else {
                knob
                label(isOn: isOn)
            }
        }
        .padding(AppSize.pillToggleKnobInset)
        .frame(width: AppSize.pillToggleWidth, height: AppSize.pillToggleHeight)
        .background(
            Capsule()
                .fill(isOn ? AppColor.textPrimary : AppColor.neutralFill)
        )
        .accessibilityHidden(true)
    }

    /// Подпись занимает место рядом с кружком и не заходит под него
    func label(isOn: Bool) -> some View {
        Text(isOn ? AppString.toggleOn : AppString.toggleOff)
            .font(.app(.microCaptionStrong))
            .foregroundStyle(isOn ? AppColor.cardBackground : AppColor.textTertiary)
            .lineLimit(1)
            .minimumScaleFactor(Constants.minLabelScaleFactor)
            .frame(maxWidth: .infinity)
    }

    var knob: some View {
        Circle()
            .fill(AppColor.cardBackground)
            .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Constants

private extension PillToggleStyle {

    enum Constants {
        static let minLabelScaleFactor: CGFloat = 0.8
    }
}

extension ToggleStyle where Self == PillToggleStyle {

    static var pill: PillToggleStyle { PillToggleStyle() }
}

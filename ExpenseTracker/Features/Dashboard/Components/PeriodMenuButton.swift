//
//  PeriodMenuButton.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import SwiftUI

/// Кнопка выбора периода в шапке главного экрана.
/// Оформлена в пару к кнопке выбора счета: та же капсула, тень и шеврон
struct PeriodMenuButton: View {

    // MARK: - Properties

    let selectedPeriod: StatisticsPeriod
    let onSelect: (StatisticsPeriod) -> Void

    // MARK: - Body

    var body: some View {
        Menu {
            ForEach(PeriodFilter.availablePeriods) { period in
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onSelect(period)
                } label: {
                    Label {
                        Text(period.displayName)
                    } icon: {
                        if selectedPeriod == period {
                            AppImage.checkmark
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: AppSpacing.smaller) {
                AppImage.calendar
                    .font(.system(size: AppSize.glyphMedium, weight: .medium))
                    .foregroundStyle(AppColor.textPrimary)

                AppText(selectedPeriod.displayName, style: .caption)
                    .contentTransition(.opacity)
                    .animation(.snappy(duration: Constants.titleDuration), value: selectedPeriod)

                AppImage.chevronDown
                    .font(.system(size: AppSize.glyphTiny, weight: .semibold))
                    .foregroundStyle(AppColor.textSecondary)
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.vertical, AppSpacing.mediumSmall)
            .background {
                Capsule()
                    .fill(AppColor.cardBackground)
                    .shadow(color: AppColor.textPrimary.opacity(Constants.shadowOpacity), radius: AppSpacing.xSmall, y: 1)
            }
        }
        .buttonStyle(PressableScaleButtonStyle())
        .accessibilityLabel(AppString.selectPeriod)
        .accessibilityValue(selectedPeriod.displayName)
    }
}

// MARK: - Constants

private extension PeriodMenuButton {

    enum Constants {
        static let shadowOpacity: Double = 0.04
        static let titleDuration: Double = 0.2
    }
}

#Preview {
    PeriodMenuButton(selectedPeriod: .month, onSelect: { _ in })
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

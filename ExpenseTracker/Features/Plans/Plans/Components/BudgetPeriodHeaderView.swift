//
//  BudgetPeriodHeaderView.swift
//  ExpenseTracker
//
//  Created by Didar on 30.08.2026.
//

import SwiftUI

/// Заголовок группы бюджетов одного периода со стрелками переключения интервала
struct BudgetPeriodHeaderView: View {

    // MARK: - Properties

    let periodName: String
    let intervalTitle: String
    let isNextEnabled: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.small) {
            arrowButton(
                image: AppImage.chevronLeft,
                label: AppString.previousPeriod,
                isEnabled: true,
                action: onPrevious
            )

            VStack(spacing: AppSpacing.xxSmall) {
                AppText(periodName, style: .sectionHeader, alignment: .center)

                AppText(
                    intervalTitle,
                    style: .microCaption,
                    color: AppColor.textSecondary,
                    alignment: .center
                )
                .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)

            arrowButton(
                image: AppImage.chevronRight,
                label: AppString.nextPeriod,
                isEnabled: isNextEnabled,
                action: onNext
            )
        }
        .padding(.horizontal, AppSpacing.xSmall)
    }
}

// MARK: - Subviews
private extension BudgetPeriodHeaderView {

    func arrowButton(
        image: Image,
        label: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            image
                .font(.system(size: AppSize.glyphMedium, weight: .semibold))
                .foregroundStyle(isEnabled ? AppColor.textPrimary : AppColor.textSecondary.opacity(0.4))
                .frame(width: AppSize.iconSmall, height: AppSize.iconSmall)
                .background {
                    Circle()
                        .fill(AppColor.cardBackground)
                }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(label)
    }
}

#Preview {
    BudgetPeriodHeaderView(
        periodName: BudgetPeriod.week.displayName,
        intervalTitle: BudgetPeriod.week.title(),
        isNextEnabled: false,
        onPrevious: {},
        onNext: {}
    )
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

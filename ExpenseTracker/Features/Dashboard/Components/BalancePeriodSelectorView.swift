//
//  BalancePeriodSelectorView.swift
//  ExpenseTracker
//
//  Created by Didar on 30.08.2026.
//

import SwiftUI

/// Подпись «Баланс» с фильтром периода и стрелками переключения
struct BalancePeriodSelectorView: View {

    // MARK: - Properties

    let filter: PeriodFilter
    let onSelect: (StatisticsPeriod) -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.smaller) {
            if filter.isNavigable {
                arrowButton(
                    image: AppImage.chevronLeft,
                    label: AppString.previousPeriod,
                    isEnabled: true,
                    action: onPrevious
                )
            }

            AppText(AppString.balance, style: .caption, color: AppColor.textSecondary)

            periodMenu

            if filter.isNavigable {
                arrowButton(
                    image: AppImage.chevronRight,
                    label: AppString.nextPeriod,
                    isEnabled: filter.canGoForward,
                    action: onNext
                )
            }
        }
    }
}

// MARK: - Subviews

private extension BalancePeriodSelectorView {

    var periodMenu: some View {
        Menu {
            ForEach(PeriodFilter.availablePeriods) { period in
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onSelect(period)
                } label: {
                    Label {
                        Text(period.displayName)
                    } icon: {
                        if filter.period == period {
                            AppImage.checkmark
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: AppSpacing.xSmall) {
                AppText(filter.title, style: .captionMedium)

                AppImage.chevronDown
                    .font(.system(size: AppSize.glyphTiny, weight: .semibold))
                    .foregroundStyle(AppColor.textSecondary)
            }
            .padding(.horizontal, AppSpacing.small)
            .padding(.vertical, AppSpacing.xSmall)
            .background {
                Capsule().fill(AppColor.fieldFill)
            }
        }
        .buttonStyle(.plain)
    }

    func arrowButton(
        image: Image,
        label: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            image
                .font(.system(size: AppSize.glyphSmall, weight: .semibold))
                .foregroundStyle(isEnabled ? AppColor.textSecondary : AppColor.textSecondary.opacity(Constants.disabledArrowOpacity))
                .frame(width: AppSize.iconSmall, height: AppSize.iconSmall)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(label)
    }
}

// MARK: - Constants

private extension BalancePeriodSelectorView {

    enum Constants {
        static let disabledArrowOpacity: Double = 0.4
    }
}

#Preview {
    BalancePeriodSelectorView(
        filter: PeriodFilter(),
        onSelect: { _ in },
        onPrevious: {},
        onNext: {}
    )
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

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
                .transition(arrowTransition)
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
                .transition(arrowTransition)
            }
        }
        // «Все время» не листается: стрелки появляются вместе со сменой периода,
        // иначе подпись прыгает вбок без объяснения
        .animation(.snappy(duration: Constants.arrowsDuration), value: filter.isNavigable)
    }
}

// MARK: - Computed Properties

private extension BalancePeriodSelectorView {

    var arrowTransition: AnyTransition {
        .opacity.combined(with: .scale(scale: Constants.arrowEnterScale))
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
        .buttonStyle(PressableScaleButtonStyle())
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
        .buttonStyle(PressableScaleButtonStyle())
        .disabled(!isEnabled)
        .accessibilityLabel(label)
    }
}

// MARK: - Constants

private extension BalancePeriodSelectorView {

    enum Constants {
        static let disabledArrowOpacity: Double = 0.4
        static let arrowsDuration: Double = 0.2
        static let arrowEnterScale: CGFloat = 0.7
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

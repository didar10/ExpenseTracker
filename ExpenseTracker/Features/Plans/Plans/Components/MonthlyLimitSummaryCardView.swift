//
//  MonthlyLimitSummaryCardView.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import SwiftUI

/// Общий лимит на месяц над бюджетами категорий. Без лимита — приглашение его задать.
/// Нажатие открывает настройку лимита
struct MonthlyLimitSummaryCardView: View {

    // MARK: - Properties

    /// nil — лимит на месяц не задан
    let summary: MonthlyLimitSummary?
    let onTap: () -> Void

    // MARK: - Body

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        } label: {
            Group {
                if let summary {
                    summaryContent(summary)
                } else {
                    promptContent
                }
            }
            .padding(AppSpacing.large)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardShadow(cornerRadius: AppRadius.card)
        }
        .buttonStyle(HighlightRowButtonStyle())
        .accessibilityHint(AppString.monthlyLimitTitle)
        .accessibilityIdentifier(AccessibilityID.budgetsMonthlyLimitCard)
    }
}

// MARK: - Subviews

private extension MonthlyLimitSummaryCardView {

    func summaryContent(_ summary: MonthlyLimitSummary) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack {
                AppText(AppString.monthlyLimitTitle, style: .caption, color: AppColor.textSecondary)

                Spacer()

                chevron
            }

            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.small) {
                Text(formatted(summary.spent))
                    .font(.app(.title))
                    .fontDesign(.rounded)
                    .monospacedDigit()
                    .foregroundStyle(AppColor.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.snappy(duration: Constants.amountDuration), value: summary)
                    .lineLimit(1)
                    .minimumScaleFactor(Constants.minAmountScaleFactor)

                AppText(AppString.ofAmount(formatted(summary.limit)), style: .caption, color: AppColor.textSecondary)
                    .lineLimit(1)
            }

            BudgetProgressBar(pace: summary.pace)

            remainingLabel(summary)

            if summary.allocated > 0 {
                Divider()
                    .padding(.vertical, AppSpacing.xSmall)

                allocationLabel(summary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    func remainingLabel(_ summary: MonthlyLimitSummary) -> some View {
        if summary.remaining >= 0 {
            AppText(
                AppString.monthlyLimitRemainingPerDay(formatted(summary.remaining), formatted(summary.perDay)),
                style: .microCaption,
                color: AppColor.textSecondary
            )
            .lineLimit(1)
        } else {
            AppText(
                "\(AppString.exceeded) \(formatted(-summary.remaining))",
                style: .microCaption,
                color: AppColor.expense
            )
            .lineLimit(1)
        }
    }

    @ViewBuilder
    func allocationLabel(_ summary: MonthlyLimitSummary) -> some View {
        if summary.isOverAllocated {
            HStack(spacing: AppSpacing.smaller) {
                AppImage.warningTriangle
                    .font(.system(size: AppSize.glyphSmall, weight: .semibold))
                    .foregroundStyle(AppColor.warning)

                AppText(
                    AppString.budgetsOverAllocated(formatted(summary.overAllocation)),
                    style: .microCaption,
                    color: AppColor.warning
                )
                .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            AppText(
                AppString.budgetsAllocated(formatted(summary.allocated)),
                style: .microCaption,
                color: AppColor.textSecondary
            )
            .lineLimit(1)
        }
    }

    var promptContent: some View {
        HStack(spacing: AppSpacing.medium) {
            ZStack {
                Circle()
                    .fill(AppColor.accent.opacity(Constants.iconFillOpacity))
                    .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)

                AppImage.dailyLimit
                    .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                    .foregroundStyle(AppColor.accent)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xxSmall) {
                AppText(AppString.budgetsLimitPromptTitle, style: .bodySmaller)

                AppText(AppString.budgetsLimitPromptHint, style: .microCaption, color: AppColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: AppSpacing.small)

            chevron
        }
    }

    var chevron: some View {
        AppImage.chevronRight
            .font(.system(size: AppSize.glyphSmall, weight: .semibold))
            .foregroundStyle(AppColor.textTertiary)
    }
}

// MARK: - Private Methods

private extension MonthlyLimitSummaryCardView {

    func formatted(_ amount: Decimal) -> String {
        amount.formatted(.currency(code: AppString.currencyCode).precision(.fractionLength(0)))
    }
}

// MARK: - Constants

private extension MonthlyLimitSummaryCardView {

    enum Constants {
        static let amountDuration: Double = 0.25
        static let minAmountScaleFactor: CGFloat = 0.7
        static let iconFillOpacity: Double = 0.15
    }
}

#Preview {
    VStack(spacing: AppSpacing.large) {
        MonthlyLimitSummaryCardView(
            summary: MonthlyLimitSummary(limit: 300_000, transactions: [], monthlyBudgets: []),
            onTap: {}
        )

        MonthlyLimitSummaryCardView(summary: nil, onTap: {})
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

//
//  DailyAllowanceCardView.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import SwiftUI

/// Карточка «Можно потратить сегодня». Без лимита — приглашение его задать.
/// Нажатие открывает настройку лимита
struct DailyAllowanceCardView: View {

    // MARK: - Properties

    /// nil — лимит на месяц не задан
    let allowance: DailyAllowance?
    let onTap: () -> Void

    // MARK: - Body

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        } label: {
            Group {
                if let allowance {
                    allowanceContent(allowance)
                } else {
                    promptContent
                }
            }
            .padding(AppSpacing.large)
            .frame(maxWidth: .infinity, alignment: .leading)
            .layeredCard()
        }
        .buttonStyle(HighlightRowButtonStyle())
        .accessibilityHint(AppString.monthlyLimitTitle)
        .accessibilityIdentifier(AccessibilityID.dailyAllowanceCard)
    }
}

// MARK: - Subviews

private extension DailyAllowanceCardView {

    func allowanceContent(_ allowance: DailyAllowance) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack {
                AppText(title(for: allowance.status), style: .caption, color: AppColor.textSecondary)

                Spacer()

                chevron
            }

            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.small) {
                Text(formatted(headlineAmount(for: allowance)))
                    .font(.app(.title))
                    .fontDesign(.rounded)
                    .monospacedDigit()
                    .foregroundStyle(headlineColor(for: allowance.status))
                    .contentTransition(.numericText())
                    .animation(.snappy(duration: Constants.amountDuration), value: allowance)
                    .lineLimit(1)
                    .minimumScaleFactor(Constants.minAmountScaleFactor)

                if allowance.status == .onTrack {
                    AppText(
                        AppString.ofAmount(formatted(allowance.todayAllowance)),
                        style: .caption,
                        color: AppColor.textSecondary
                    )
                    .lineLimit(1)
                }
            }

            progressBar(allowance)
                .padding(.vertical, AppSpacing.xSmall)

            AppText(footer(for: allowance), style: .microCaption, color: AppColor.textSecondary)
                .lineLimit(1)
        }
        .accessibilityElement(children: .combine)
    }

    func progressBar(_ allowance: DailyAllowance) -> some View {
        Capsule()
            .fill(AppColor.subtleFill)
            .frame(height: AppSize.progressBar)
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    Capsule()
                        .fill(barColor(for: allowance.status))
                        .frame(width: proxy.size.width * barFraction(for: allowance))
                }
            }
            .clipShape(Capsule())
            .animation(.snappy(duration: Constants.amountDuration), value: allowance)
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
                AppText(AppString.monthlyLimitPromptTitle, style: .bodySmaller)

                AppText(AppString.monthlyLimitPromptHint, style: .microCaption, color: AppColor.textSecondary)
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

private extension DailyAllowanceCardView {

    func title(for status: DailyAllowance.Status) -> String {
        switch status {
        case .onTrack: return AppString.canSpendToday
        case .overToday: return AppString.overspentToday
        case .overMonth: return AppString.monthlyLimitExceeded
        }
    }

    /// Остаток на сегодня, перерасход за день или превышение месячного лимита
    func headlineAmount(for allowance: DailyAllowance) -> Decimal {
        switch allowance.status {
        case .onTrack: return allowance.todayRemaining
        case .overToday: return -allowance.todayRemaining
        case .overMonth: return -allowance.monthRemaining
        }
    }

    func headlineColor(for status: DailyAllowance.Status) -> Color {
        switch status {
        case .onTrack: return AppColor.textPrimary
        case .overToday: return AppColor.warning
        case .overMonth: return AppColor.expense
        }
    }

    func barColor(for status: DailyAllowance.Status) -> Color {
        switch status {
        case .onTrack: return AppColor.income
        case .overToday: return AppColor.warning
        case .overMonth: return AppColor.expense
        }
    }

    /// При перерасходе полоска заполнена цветом предупреждения целиком
    func barFraction(for allowance: DailyAllowance) -> CGFloat {
        allowance.status == .onTrack ? allowance.todayRemainingFraction : 1
    }

    func footer(for allowance: DailyAllowance) -> String {
        switch allowance.status {
        case .onTrack, .overToday:
            return AppString.monthRemainingFooter(formatted(allowance.monthRemaining), allowance.daysLeft)
        case .overMonth:
            return AppString.monthlyLimitFooter(formatted(allowance.monthlyLimit))
        }
    }

    func formatted(_ amount: Decimal) -> String {
        amount.formatted(.currency(code: AppString.currencyCode).precision(.fractionLength(0)))
    }
}

// MARK: - Constants

private extension DailyAllowanceCardView {

    enum Constants {
        static let amountDuration: Double = 0.25
        static let minAmountScaleFactor: CGFloat = 0.7
        static let iconFillOpacity: Double = 0.15
    }
}

#Preview {
    VStack(spacing: AppSpacing.large) {
        DailyAllowanceCardView(
            allowance: DailyAllowance(monthlyLimit: 300_000, transactions: []),
            onTap: {}
        )

        DailyAllowanceCardView(allowance: nil, onTap: {})
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

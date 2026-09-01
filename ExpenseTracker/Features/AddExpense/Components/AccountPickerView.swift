//
//  AccountPickerView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI

struct AccountPickerView: View {

    // MARK: - Properties

    let account: Account?
    /// Баланс счета после этой операции; nil — сумма еще не введена, показываем текущий баланс
    let predictedBalance: Decimal?
    let onTap: () -> Void

    // MARK: - Computed Properties

    private var balance: Decimal? {
        predictedBalance ?? account?.currentBalance
    }

    private var balanceText: String {
        balance?.formatted(.currency(code: AppString.currencyCode)) ?? ""
    }

    /// Уход счета в минус — единственное, что подсвечивается цветом в этой плитке
    private var balanceColor: Color {
        (balance ?? 0) < 0 ? AppColor.expense : AppColor.textPrimary
    }

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.mediumSmall) {
                if let account {
                    accountIcon(for: account)
                    accountDetails(for: account)
                } else {
                    placeholder
                }
            }
            .padding(.horizontal, AppSpacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: AppSize.inlineTile)
            .card(cornerRadius: AppRadius.card)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(account?.name ?? AppString.chooseAccount)
        .accessibilityValue(balanceText)
        .accessibilityHint(AppString.selectAccount)
    }
}

// MARK: - Subviews
private extension AccountPickerView {

    func accountIcon(for account: Account) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous)
                .fill(account.swiftUIColor.opacity(0.2))
                .frame(width: AppSize.tileIcon, height: AppSize.tileIcon)

            Image(systemName: account.icon)
                .font(.system(size: AppSize.glyphMedium))
                .foregroundStyle(account.swiftUIColor)
        }
    }

    func accountDetails(for account: Account) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxSmall) {
            Text(account.name)
                .font(.app(.microCaption))
                .foregroundStyle(AppColor.textSecondary)
                .lineLimit(1)

            Text(balanceText)
                .font(.app(.bodySmall))
                .fontDesign(.rounded)
                .monospacedDigit()
                .foregroundStyle(balanceColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .contentTransition(.numericText())
                .animation(.snappy(duration: 0.2), value: balance)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var placeholder: some View {
        HStack(spacing: AppSpacing.mediumSmall) {
            AppImage.creditcard
                .font(.system(size: AppSize.glyphXLarge))
                .foregroundStyle(AppColor.textSecondary)

            Text(AppString.chooseAccount)
                .font(.app(.bodySmaller))
                .foregroundStyle(AppColor.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)
        }
    }
}

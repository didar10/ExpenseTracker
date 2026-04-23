//
//  AccountPickerButton.swift
//  ExpenseTracker
//
//  Created by Didar on 01.02.2026.
//

import SwiftUI

/// Переиспользуемая кнопка для выбора счета
struct AccountPickerButton: View {

    // MARK: - Properties

    let selectedAccount: Account?
    let totalBalance: Decimal
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            HStack(spacing: AppSpacing.smaller) {
                if let selectedAccount {
                    accountIcon(selectedAccount)
                    accountInfo(selectedAccount)
                } else {
                    allAccountsIcon
                    allAccountsInfo
                }

                chevronIcon
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.vertical, AppSpacing.small)
            .background {
                Capsule()
                    .fill(AppColor.cardBackground)
                    .shadow(color: AppColor.textPrimary.opacity(0.04), radius: AppSpacing.xSmall, y: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Subviews

private extension AccountPickerButton {

    func accountIcon(_ account: Account) -> some View {
        ZStack {
            Circle()
                .fill(account.swiftUIColor.opacity(0.2))
                .frame(width: AppSize.iconSmall, height: AppSize.iconSmall)

            Image(systemName: account.icon)
                .font(.system(size: AppSize.glyphSmall, weight: .medium))
                .foregroundStyle(account.swiftUIColor)
        }
    }

    func accountInfo(_ account: Account) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.hairline) {
            AppText(account.name, style: .caption)

            Text(account.currentBalance.formatted(.currency(code: AppString.currencyCode)))
                .font(.app(.microCaption))
                .fontDesign(.rounded)
                .foregroundStyle(AppColor.textSecondary)
        }
    }

    var allAccountsIcon: some View {
        AppImage.allAccounts
            .font(.system(size: AppSize.glyphLarge, weight: .medium))
            .foregroundStyle(AppColor.textPrimary)
    }

    var allAccountsInfo: some View {
        VStack(alignment: .leading, spacing: AppSpacing.hairline) {
            AppText(AppString.allAccounts, style: .caption)

            Text(totalBalance.formatted(.currency(code: AppString.currencyCode)))
                .font(.app(.microCaption))
                .fontDesign(.rounded)
                .foregroundStyle(AppColor.textSecondary)
        }
    }

    var chevronIcon: some View {
        AppImage.chevronDown
            .font(.system(size: AppSize.glyphTiny, weight: .semibold))
            .foregroundStyle(AppColor.textSecondary)
    }
}

// MARK: - Preview

#Preview("Selected Account") {
    let account = Account(
        name: "Основной счёт",
        icon: "creditcard.fill",
        color: "blue",
        initialBalance: 150000
    )

    return AccountPickerButton(
        selectedAccount: account,
        totalBalance: 150000,
        action: {}
    )
    .padding(AppSpacing.large)
}

#Preview("All Accounts") {
    AccountPickerButton(
        selectedAccount: nil,
        totalBalance: 350000,
        action: {}
    )
    .padding(AppSpacing.large)
}

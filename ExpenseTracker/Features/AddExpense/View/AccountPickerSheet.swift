//
//  AccountPickerSheet.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI

struct AccountPickerSheet: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @Binding var selectedAccount: Account?
    let accounts: [Account]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background
                    .ignoresSafeArea()

                if accounts.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(accounts) { account in
                                Button {
                                    selectedAccount = account
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    dismiss()
                                } label: {
                                    accountRow(account)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(AppString.selectAccount)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ToolbarIconButton(icon: "xmark") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Subviews
private extension AccountPickerSheet {

    func accountRow(_ account: Account) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(account.swiftUIColor.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: account.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(account.swiftUIColor)
            }

            HStack(spacing: 4) {
                Text(account.name)
                    .font(.app(.bodySmaller))
                    .foregroundStyle(AppColor.textPrimary)

                if account.isDefault {
                    AppImage.starFill
                        .font(.system(size: 10))
                        .foregroundStyle(AppColor.highlight)
                }
            }

            Spacer(minLength: 8)

            HStack(spacing: 8) {
                Text(account.currentBalance.formatted(.currency(code: AppString.currencyCode)))
                    .font(.app(.caption))
                    .fontDesign(.rounded)
                    .foregroundStyle(AppColor.textSecondary)

                if selectedAccount?.id == account.id {
                    AppImage.checkmarkCircleFill
                        .font(.system(size: 20))
                        .foregroundStyle(AppColor.accent)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .cardShadow(cornerRadius: 14)
    }

    var emptyStateView: some View {
        VStack(spacing: 20) {
            AppImage.noAccountsIcon
                .font(.system(size: 60))
                .foregroundStyle(AppColor.textSecondary)

            AppText(AppString.noAccounts, style: .title)
                .color(AppColor.textPrimary)

            AppText(AppString.noAccountsHint, style: .body)
                .color(AppColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

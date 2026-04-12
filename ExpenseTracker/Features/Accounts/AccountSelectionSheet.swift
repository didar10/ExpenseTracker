//
//  AccountSelectionSheet.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI

struct AccountSelectionSheet: View {

    // MARK: - Properties

    let accounts: [Account]
    let selectedAccount: Account?
    let onSelect: (Account?) -> Void
    let onShowAll: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showingAddAccount = false
    @State private var editingAccount: Account?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            onSelect(nil)
                        } label: {
                            allAccountsRow
                        }
                        .buttonStyle(.plain)

                        ForEach(accounts) { account in
                            accountRow(account)
                        }
                    }
                    .padding()
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

                ToolbarItem(placement: .navigationBarTrailing) {
                    ToolbarIconButton(icon: "plus") {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        showingAddAccount = true
                    }
                }
            }
            .sheet(isPresented: $showingAddAccount) {
                AccountFormView()
            }
            .sheet(item: $editingAccount) { account in
                AccountFormView(account: account)
            }
        }
    }
}

// MARK: - Subviews
private extension AccountSelectionSheet {

    var allAccountsRow: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppColor.accent.opacity(0.2))
                    .frame(width: 56, height: 56)

                AppImage.allAccounts
                    .font(.system(size: 24))
                    .foregroundStyle(AppColor.accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                AppText(AppString.allAccounts, style: .section)
                    .color(AppColor.textPrimary)

                AppText(AppString.allAccountsHint, style: .caption)
                    .color(AppColor.textSecondary)
            }

            Spacer()

            if selectedAccount == nil {
                AppImage.checkmarkCircleFill
                    .font(.system(size: 24))
                    .foregroundStyle(AppColor.accent)
            }
        }
        .padding(16)
        .cardShadow(cornerRadius: 16)
    }

    func accountRow(_ account: Account) -> some View {
        HStack(spacing: 12) {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onSelect(account)
            } label: {
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
            }
            .buttonStyle(.plain)

            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                editingAccount = account
            } label: {
                ZStack {
                    Circle()
                        .fill(AppColor.secondaryBackground)
                        .frame(width: 40, height: 40)

                    AppImage.pencil
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColor.textPrimary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .cardShadow(cornerRadius: 14)
    }
}

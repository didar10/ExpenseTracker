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
    var allowsAllAccounts: Bool = true

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var showingAddAccount = false
    @State private var editingAccount: Account?
    @State private var isEditing = false
    @State private var accountToDelete: Account?
    @State private var showDeleteAlert = false

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: AppSpacing.large) {
                        if isEditing || !allowsAllAccounts {
                            allAccountsRow
                                .opacity(allowsAllAccounts ? 1 : 0.4)
                        } else {
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                onSelect(nil)
                            } label: {
                                allAccountsRow
                            }
                            .buttonStyle(.plain)
                        }

                        accountsList
                    }
                    .padding(AppSpacing.large)
                }
            }

            if !isEditing {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showingAddAccount = true
                } label: {
                    AccountAddFloatingButton()
                }
                .padding(.trailing, AppSpacing.large)
                .padding(.bottom, AppSpacing.xxxLarge)
            }
        }
        .sheet(isPresented: $showingAddAccount) {
            AccountFormView()
        }
        .sheet(item: $editingAccount) { account in
            AccountFormView(account: account)
        }
        .alert(AppString.deleteAccountConfirm, isPresented: $showDeleteAlert) {
            Button(AppString.cancel, role: .cancel) {
                accountToDelete = nil
            }
            Button(AppString.delete, role: .destructive) {
                if let account = accountToDelete {
                    context.delete(account)
                    try? context.save()
                    accountToDelete = nil
                }
            }
        } message: {
            Text(AppString.cannotUndo)
        }
    }
}

// MARK: - Subviews
private extension AccountSelectionSheet {

    var header: some View {
        ZStack {
            AppText(AppString.selectAccount, style: .bodySmall)

            HStack {
                ToolbarIconButton(icon: "xmark", isOutlined: true) {
                    dismiss()
                }

                Spacer()

                if !accounts.isEmpty {
                    AccountEditToggleButton(isEditing: isEditing) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditing.toggle()
                        }
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.small)
        .padding(.top, AppSpacing.medium)
    }

    var accountsList: some View {
        CategoriesCardView {
            VStack(spacing: 0) {
                ForEach(Array(accounts.enumerated()), id: \.element.id) { index, account in
                    accountRowContent(for: account)

                    if index < accounts.count - 1 {
                        Divider()
                            .padding(.leading, AppSpacing.listDividerIndent)
                    }
                }
            }
        }
    }

    @ViewBuilder
    func accountRowContent(for account: Account) -> some View {
        if isEditing {
            AccountRowView(
                account: account,
                isEditing: true,
                onEdit: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    editingAccount = account
                },
                onDelete: {
                    accountToDelete = account
                    showDeleteAlert = true
                }
            )
        } else {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onSelect(account)
            } label: {
                AccountRowView(
                    account: account,
                    isEditing: false,
                    onEdit: {},
                    onDelete: {}
                )
            }
            .buttonStyle(.plain)
        }
    }

    var allAccountsRow: some View {
        HStack(spacing: AppSpacing.medium) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .fill(AppColor.accent.opacity(0.2))
                    .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)

                AppImage.allAccounts
                    .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
            }

            AppText(AppString.allAccounts, style: .bodySmall)

            Spacer()

            Text(totalBalance.formatted(.currency(code: AppString.currencyCode)))
                .font(.app(.caption))
                .fontDesign(.rounded)
                .foregroundStyle(AppColor.textSecondary)
        }
        .padding(.vertical, AppSpacing.small)
        .padding(.horizontal, AppSpacing.large)
        .card(cornerRadius: AppRadius.xLarge)
    }

    var totalBalance: Decimal {
        accounts.reduce(Decimal.zero) { $0 + $1.currentBalance }
    }
}

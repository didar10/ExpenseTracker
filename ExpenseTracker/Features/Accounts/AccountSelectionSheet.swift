//
//  AccountSelectionSheet.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI
import SwiftData

struct AccountSelectionSheet: View {

    // MARK: - Properties

    let selectedAccount: Account?
    let onSelect: (Account?) -> Void
    /// Разрешён ли вариант «Все счета»: при вводе операции счет обязателен
    var allowsAllAccounts: Bool = true

    /// Список счетов читается своим запросом, а не приходит снимком от экрана-родителя:
    /// после удаления родитель может отдать массив с уже невалидной моделью, обращение
    /// к её свойствам роняет SwiftData
    @Query(sort: \Account.createdAt, order: .forward)
    private var accounts: [Account]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var showingAddAccount = false
    @State private var editingAccount: Account?
    @State private var isEditing = false
    @State private var accountToDelete: Account?
    @State private var showDeleteAlert = false

    // MARK: - Computed Properties

    private var totalBalance: Decimal {
        accounts.reduce(Decimal.zero) { $0 + $1.currentBalance }
    }

    private var isAllAccountsSelected: Bool {
        selectedAccount == nil
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                content
            }

            if !isEditing && !accounts.isEmpty {
                AddFloatingButton(title: AppString.newAccountShort) {
                    showingAddAccount = true
                }
                .padding(.trailing, AppSpacing.large)
                .padding(.bottom, AppSpacing.xxxLarge)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        // Список опустел — редактировать больше нечего
        .onChange(of: accounts.isEmpty) { _, isEmpty in
            if isEmpty {
                isEditing = false
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
            Button(AppString.delete, role: .destructive, action: deleteAccount)
        } message: {
            // Вместе со счетом каскадом удаляются его операции — предупреждаем об этом явно
            Text(AppString.deleteAccountMessage)
        }
    }
}

// MARK: - Subviews
private extension AccountSelectionSheet {

    var header: some View {
        SheetHeaderView(title: AppString.selectAccount) {
            dismiss()
        } trailing: {
            if !accounts.isEmpty {
                EditToggleButton(isEditing: isEditing) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditing.toggle()
                    }
                }
                .accessibilityLabel(isEditing ? AppString.done : AppString.edit)
            }
        }
    }

    @ViewBuilder
    var content: some View {
        ScrollView {
            VStack(spacing: AppSpacing.large) {
                if accounts.isEmpty {
                    EmptyAccountsView {
                        showingAddAccount = true
                    }
                } else {
                    if allowsAllAccounts {
                        allAccountsRow
                    }

                    accountsList
                }
            }
            .padding(AppSpacing.large)
            // Плавающая кнопка не должна перекрывать последнюю строку списка
            .padding(.bottom, AppSpacing.huge + AppSpacing.xxxLarge)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    @ViewBuilder
    var allAccountsRow: some View {
        if isEditing {
            allAccountsRowContent
        } else {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onSelect(nil)
            } label: {
                allAccountsRowContent
            }
            .buttonStyle(HighlightRowButtonStyle(cornerRadius: AppRadius.xLarge))
            .accessibilityAddTraits(isAllAccountsSelected ? .isSelected : [])
        }
    }

    var allAccountsRowContent: some View {
        HStack(spacing: AppSpacing.medium) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .fill(AppColor.accent.opacity(0.2))
                    .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)

                AppImage.allAccounts
                    .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                    .foregroundStyle(AppColor.accent)
            }
            .accessibilityHidden(true)

            AppText(AppString.allAccounts, style: .bodySmall)

            Spacer(minLength: AppSpacing.small)

            Text(totalBalance.formatted(.currency(code: AppString.currencyCode)))
                .font(.app(.caption))
                .fontDesign(.rounded)
                .monospacedDigit()
                .foregroundStyle(AppColor.textSecondary)
                .lineLimit(1)

            AppImage.checkmark
                .font(.system(size: AppSize.glyphMedium, weight: .semibold))
                .foregroundStyle(AppColor.accent)
                .opacity(isAllAccountsSelected ? 1 : 0)
                .accessibilityHidden(true)
        }
        .padding(.vertical, AppSpacing.small)
        .padding(.horizontal, AppSpacing.large)
        .frame(minHeight: AppSize.iconLarge)
        .card(cornerRadius: AppRadius.xLarge)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    var accountsList: some View {
        // Отступы совпадают со строкой «Все счета»: одинаковая высота строк в обеих карточках
        VStack(spacing: 0) {
            ForEach(Array(accounts.enumerated()), id: \.element.id) { index, account in
                accountRowContent(for: account)

                if index < accounts.count - 1 {
                    Divider()
                        .padding(.leading, AppSize.iconMedium + AppSpacing.medium)
                }
            }
        }
        .padding(.vertical, AppSpacing.small)
        .padding(.horizontal, AppSpacing.large)
        .card(cornerRadius: AppRadius.xLarge)
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
                    isSelected: account === selectedAccount,
                    onEdit: {},
                    onDelete: {}
                )
            }
            .buttonStyle(HighlightRowButtonStyle(cornerRadius: AppRadius.medium))
        }
    }
}

// MARK: - Actions
private extension AccountSelectionSheet {

    func deleteAccount() {
        guard let accountToDelete else { return }

        context.delete(accountToDelete)
        try? context.save()

        self.accountToDelete = nil
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

#Preview {
    AccountSelectionSheet(selectedAccount: nil, onSelect: { _ in })
        .modelContainer(for: [Account.self], inMemory: true)
}

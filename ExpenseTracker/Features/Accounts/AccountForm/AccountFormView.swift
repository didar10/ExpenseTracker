//
//  AccountFormView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI
import SwiftData

struct AccountFormView: View {

    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Account.name) private var accounts: [Account]

    @StateObject private var viewModel: AccountFormViewModel

    @State private var showingDeleteAlert = false

    // MARK: - Init

    init(account: Account? = nil) {
        _viewModel = StateObject(wrappedValue: AccountFormViewModel(account: account))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        accountPreviewCard
                        formContent
                    }
                    .padding()
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ToolbarIconButton(icon: "xmark") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    ToolbarIconButton(icon: "checkmark", isEnabled: viewModel.isValid) {
                        viewModel.save(accounts: accounts, using: modelContext)
                        dismiss()
                    }
                }
            }
            .alert(AppString.deleteAccountConfirm, isPresented: $showingDeleteAlert) {
                Button(AppString.cancel, role: .cancel) { }
                Button(AppString.delete, role: .destructive) {
                    viewModel.delete(using: modelContext)
                    dismiss()
                }
            } message: {
                Text(AppString.deleteAccountMessage)
            }
        }
    }
}

// MARK: - Subviews
private extension AccountFormView {

    var accountPreviewCard: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(named: viewModel.selectedColor).opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: viewModel.selectedIcon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color(named: viewModel.selectedColor))
            }

            HStack {
                TextField(AppString.accountName, text: $viewModel.name)
                    .font(.app(.bodySmaller))
                    .foregroundStyle(viewModel.name.isEmpty ? AppColor.textSecondary : AppColor.textPrimary)

                if viewModel.isDefault {
                    AppImage.starFill
                        .font(.system(size: 11))
                        .foregroundStyle(AppColor.highlight)
                }
            }

            Spacer()
        }
        .padding(16)
        .card(cornerRadius: 16)
    }

    var formContent: some View {
        VStack(spacing: 16) {
            FormSection(title: AppString.initialBalance) {
                TextField("0", text: $viewModel.initialBalance)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .font(.app(.body))
            }

            FormSection(title: AppString.icon) {
                IconPickerView(selectedIcon: $viewModel.selectedIcon, onSelect: viewModel.selectIcon)
            }

            FormSection(title: AppString.color) {
                ColorPickerView(selectedColor: $viewModel.selectedColor, onSelect: viewModel.selectColor)
            }

            FormSection(title: "") {
                Toggle(isOn: $viewModel.isDefault) {
                    VStack(alignment: .leading, spacing: 2) {
                        AppText(AppString.defaultAccount, style: .body)
                            .color(AppColor.textPrimary)
                        AppText(AppString.defaultAccountHint, style: .caption)
                            .color(AppColor.textSecondary)
                    }
                }
                .tint(AppColor.accent)
            }

            if viewModel.isEditMode {
                Button {
                    showingDeleteAlert = true
                } label: {
                    HStack {
                        Spacer()

                        HStack(spacing: 8) {
                            AppImage.trash
                                .font(.system(size: 15, weight: .semibold))

                            AppText(AppString.deleteAccount, style: .bodySmaller)
                        }
                        .foregroundStyle(AppColor.expense)

                        Spacer()
                    }
                    .padding(16)
                    .cardShadow(cornerRadius: 12)
                }
            }
        }
    }
}

#Preview {
    AccountFormView()
        .modelContainer(for: [Account.self], inMemory: true)
}

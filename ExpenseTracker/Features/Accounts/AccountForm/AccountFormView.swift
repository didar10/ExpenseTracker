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
        ZStack(alignment: .bottom) {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: AppSpacing.xLarge) {
                        NamePreviewCardView(
                            name: $viewModel.name,
                            icon: viewModel.selectedIcon,
                            color: Color(named: viewModel.selectedColor),
                            placeholder: AppString.accountName
                        )

                        colorSection
                        iconSection
                        balanceSection
                        defaultSection

                        if viewModel.isEditMode {
                            deleteSection
                        }
                    }
                    .padding(AppSpacing.large)
                    .padding(.bottom, AppSpacing.huge + AppSpacing.xxxLarge)
                }
            }

            saveBar
        }
        .alert(AppString.deleteAccountConfirm, isPresented: $showingDeleteAlert) {
            Button(AppString.cancel, role: .cancel) { }
            Button(AppString.delete, role: .destructive) {
                viewModel.delete(using: modelContext)
                dismiss()
            }
        } message: {
            Text(AppString.cannotUndo)
        }
    }
}

// MARK: - Subviews
private extension AccountFormView {

    var header: some View {
        ZStack {
            AppText(viewModel.navigationTitle, style: .bodySmall)

            HStack {
                ToolbarIconButton(icon: "xmark", isOutlined: true) {
                    dismiss()
                }

                Spacer()
            }
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.small)
        .padding(.top, AppSpacing.medium)
    }

    var balanceSection: some View {
        HStack(spacing: AppSpacing.medium) {
            AppText(AppString.initialBalance, style: .bodySmall)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

            TextField("0", text: $viewModel.initialBalance)
                .keyboardType(.decimalPad)
                .font(.app(.body))
                .multilineTextAlignment(.trailing)
        }
        .padding(AppSpacing.large)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColor.fieldFill)
        )
    }

    var iconSection: some View {
        IconPickerView(
            selectedIcon: $viewModel.selectedIcon,
            color: Color(named: viewModel.selectedColor),
            onSelect: viewModel.selectIcon
        )
    }

    var colorSection: some View {
        ColorPickerView(selectedColor: $viewModel.selectedColor, onSelect: viewModel.selectColor)
    }

    var defaultSection: some View {
        Toggle(isOn: $viewModel.isDefault) {
            VStack(alignment: .leading, spacing: 2) {
                AppText(AppString.defaultAccount, style: .bodySmall)
                AppText(AppString.defaultAccountHint, style: .caption, color: AppColor.textSecondary)
            }
        }
        .tint(AppColor.accent)
        .padding(AppSpacing.large)
        .card(cornerRadius: AppRadius.card, fillColor: AppColor.fieldFill)
    }

    var deleteSection: some View {
        Button {
            showingDeleteAlert = true
        } label: {
            HStack {
                Spacer()

                HStack(spacing: AppSpacing.small) {
                    AppImage.trash
                        .font(.system(size: AppSize.glyphLarge, weight: .semibold))

                    AppText(AppString.deleteAccount, style: .bodySmall)
                }
                .foregroundStyle(AppColor.expense)

                Spacer()
            }
            .padding(AppSpacing.large)
            .card(cornerRadius: AppRadius.card, fillColor: AppColor.fieldFill)
        }
        .buttonStyle(.plain)
    }

    var saveBar: some View {
        CategorySaveButtonView(
            title: viewModel.saveButtonTitle,
            isEnabled: viewModel.isValid,
            action: handleSave
        )
        .padding(.horizontal, AppSpacing.large)
        .padding(.top, AppSpacing.medium)
        .padding(.bottom, AppSpacing.large)
        .background(
            AppColor.background
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Actions
private extension AccountFormView {

    func handleSave() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        withAnimation {
            viewModel.save(accounts: accounts, using: modelContext)
            dismiss()
        }
    }
}

#Preview {
    AccountFormView()
        .modelContainer(for: [Account.self], inMemory: true)
}

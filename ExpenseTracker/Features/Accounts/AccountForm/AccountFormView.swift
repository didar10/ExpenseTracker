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
                        accountPreviewCard

                        nameSection
                        balanceSection
                        iconSection
                        colorSection
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
            AppText(viewModel.navigationTitle, style: .section)

            HStack {
                ToolbarIconButton(icon: "xmark", isOutlined: true) {
                    dismiss()
                }

                Spacer()
            }
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.small)
    }

    var accountPreviewCard: some View {
        VStack(spacing: AppSpacing.large) {
            AppText(
                AppString.preview.uppercased(),
                style: .microCaption,
                color: AppColor.textSecondary
            )
            .tracking(AppSpacing.hairline)

            HStack(spacing: AppSpacing.small) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .fill(Color(named: viewModel.selectedColor).opacity(0.2))
                        .frame(width: AppSize.iconLarge, height: AppSize.iconLarge)

                    Image(systemName: viewModel.selectedIcon)
                        .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                        .foregroundStyle(Color(named: viewModel.selectedColor))
                }

                VStack(alignment: .leading, spacing: 2) {
                    AppText(
                        viewModel.previewName,
                        style: .bodySmall,
                        color: viewModel.previewNameColor
                    )

                    if let balance = viewModel.previewBalance {
                        Text(balance)
                            .font(.app(.caption))
                            .fontDesign(.rounded)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }

                if viewModel.isDefault {
                    AppImage.starFill
                        .font(.system(size: 10))
                        .foregroundStyle(AppColor.highlight)
                }

                Spacer()
            }
            .padding(AppSpacing.large)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .fill(AppColor.cardBackground)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xLarge)
        .padding(.horizontal, AppSpacing.large)
        .card(cornerRadius: AppRadius.xLarge)
    }

    var nameSection: some View {
        CategoryFormSectionView(title: AppString.name.uppercased()) {
            TextField(AppString.accountName, text: $viewModel.name)
                .font(.app(.body))
                .padding(AppSpacing.large)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .fill(AppColor.cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .strokeBorder(
                            AppColor.textPrimary.opacity(0.15),
                            lineWidth: AppSpacing.hairline
                        )
                )
        }
    }

    var balanceSection: some View {
        CategoryFormSectionView(title: AppString.initialBalance.uppercased()) {
            TextField("0", text: $viewModel.initialBalance)
                .keyboardType(.decimalPad)
                .font(.app(.body))
                .padding(AppSpacing.large)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .fill(AppColor.cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .strokeBorder(
                            AppColor.textPrimary.opacity(0.15),
                            lineWidth: AppSpacing.hairline
                        )
                )
        }
    }

    var iconSection: some View {
        CategoryFormSectionView(title: AppString.icon.uppercased()) {
            IconPickerView(selectedIcon: $viewModel.selectedIcon, onSelect: viewModel.selectIcon)
        }
    }

    var colorSection: some View {
        CategoryFormSectionView(title: AppString.color.uppercased()) {
            ColorPickerView(selectedColor: $viewModel.selectedColor, onSelect: viewModel.selectColor)
        }
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
        .card(cornerRadius: AppRadius.card)
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
            .card(cornerRadius: AppRadius.card)
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

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

    @FocusState private var isBalanceFocused: Bool

    @State private var showingDeleteAlert = false
    @State private var showingDiscardConfirmation = false

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

                form
            }

            saveBar
        }
        // Введенные данные не теряются молча: закрытие проходит через подтверждение
        .interactiveDismissDisabled(viewModel.hasUnsavedChanges)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button(AppString.done) {
                    isBalanceFocused = false
                    dismissKeyboard()
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
            // Вместе со счетом каскадом удаляются его операции — предупреждаем об этом явно
            Text(AppString.deleteAccountMessage)
        }
        .alert(AppString.discardAccountTitle, isPresented: $showingDiscardConfirmation) {
            Button(AppString.discardChanges, role: .destructive) { dismiss() }
            Button(AppString.keepEditing, role: .cancel) { }
        } message: {
            Text(AppString.discardChangesMessage)
        }
    }
}

// MARK: - Subviews
private extension AccountFormView {

    var header: some View {
        SheetHeaderView(title: viewModel.navigationTitle, onClose: handleClose)
    }

    var form: some View {
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
        .scrollDismissesKeyboard(.interactively)
    }

    var colorSection: some View {
        ColorPickerView(selectedColor: $viewModel.selectedColor, onSelect: viewModel.selectColor)
    }

    var iconSection: some View {
        AccountIconPickerView(
            selectedIcon: $viewModel.selectedIcon,
            color: Color(named: viewModel.selectedColor),
            onSelect: viewModel.selectIcon
        )
    }

    var balanceSection: some View {
        HStack(spacing: AppSpacing.medium) {
            AppText(AppString.initialBalance, style: .bodySmall)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

            TextField("0", text: $viewModel.initialBalance)
                .keyboardType(.decimalPad)
                .focused($isBalanceFocused)
                .font(.app(.body))
                .fontDesign(.rounded)
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
                .onChange(of: viewModel.initialBalance) {
                    viewModel.sanitizeBalanceInput()
                }

            AppText(AppString.currencySymbol, style: .body, color: AppColor.textSecondary)
        }
        .padding(AppSpacing.large)
        .frame(minHeight: AppSize.inlineTile)
        .card(cornerRadius: AppRadius.card, fillColor: AppColor.fieldFill)
        .contentShape(Rectangle())
        .onTapGesture {
            isBalanceFocused = true
        }
    }

    var defaultSection: some View {
        Toggle(isOn: $viewModel.isDefault) {
            VStack(alignment: .leading, spacing: AppSpacing.xxSmall) {
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
            dismissKeyboard()
            showingDeleteAlert = true
        } label: {
            HStack(spacing: AppSpacing.small) {
                AppImage.trash
                    .font(.system(size: AppSize.glyphLarge, weight: .semibold))

                AppText(AppString.deleteAccount, style: .bodySmall, color: AppColor.expense)
            }
            .foregroundStyle(AppColor.expense)
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.large)
            .card(cornerRadius: AppRadius.card, fillColor: AppColor.expense.opacity(0.1))
        }
        .buttonStyle(PressableScaleButtonStyle())
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
        dismissKeyboard()

        viewModel.save(accounts: accounts, using: modelContext)
        dismiss()
    }

    func handleClose() {
        dismissKeyboard()

        guard viewModel.hasUnsavedChanges else {
            dismiss()
            return
        }

        showingDiscardConfirmation = true
    }

    func dismissKeyboard() {
        isBalanceFocused = false

        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

#Preview("Новый счет") {
    AccountFormView()
        .modelContainer(for: [Account.self], inMemory: true)
}

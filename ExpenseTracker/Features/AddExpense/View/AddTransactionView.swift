//
//  AddTransactionView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI
import SwiftData

struct AddTransactionView: View {

    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: AddTransactionViewModel

    @FocusState private var isNoteFocused: Bool

    @State private var showingAccountPicker = false
    @State private var showingDiscardConfirmation = false
    @State private var isContentScrolled = false

    @Query(sort: \Category.name)
    private var categories: [Category]

    @Query(sort: \Account.createdAt, order: .forward)
    private var accounts: [Account]

    // MARK: - Init

    init(transaction: Transaction? = nil, accountSelection: AccountSelectionStore) {
        _viewModel = StateObject(
            wrappedValue: AddTransactionViewModel(
                transaction: transaction,
                accountSelection: accountSelection
            )
        )
    }

    // MARK: - Computed Properties

    private var filteredCategories: [Category] {
        categories.filter { $0.type == viewModel.type }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header

                form

                // Клавиатура заметки заменяет цифровую: две клавиатуры одновременно не нужны
                if !isNoteFocused {
                    keypad
                }
            }
            .background(AppColor.background)
            .animation(.easeOut(duration: 0.25), value: isNoteFocused)
            .overlay {
                if viewModel.showSuccessAnimation {
                    SuccessOverlayView()
                        .transition(.opacity.combined(with: .scale(scale: 0.92)))
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button(AppString.done) { isNoteFocused = false }
                }
            }
            .onChange(of: viewModel.type) {
                viewModel.resetCategoryIfTypeMismatched()
            }
            // Выбор категории завершает ввод заметки
            .onChange(of: viewModel.selectedCategory) {
                isNoteFocused = false
            }
            .task(id: accounts.count) {
                viewModel.applyDefaultAccountIfNeeded(from: accounts)
            }
            // Введенные данные не теряются молча: закрытие проходит через подтверждение
            .interactiveDismissDisabled(viewModel.hasUnsavedChanges)
            .alert(AppString.discardChangesTitle, isPresented: $showingDiscardConfirmation) {
                Button(AppString.discardChanges, role: .destructive) { dismiss() }
                Button(AppString.keepEditing, role: .cancel) {}
            } message: {
                Text(AppString.discardChangesMessage)
            }
            .sheet(isPresented: $showingAccountPicker) {
                accountSelectionSheet
            }
        }
    }
}

// MARK: - Actions
private extension AddTransactionView {

    func handleSave() {
        guard viewModel.save(using: modelContext) else { return }

        isNoteFocused = false

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            viewModel.showSuccessAndDismiss {
                dismiss()
            }
        }
    }

    func handleClose() {
        isNoteFocused = false

        guard viewModel.hasUnsavedChanges else {
            dismiss()
            return
        }

        showingDiscardConfirmation = true
    }
}

// MARK: - Subviews
private extension AddTransactionView {

    var header: some View {
        ZStack {
            HStack {
                Spacer()

                TransactionTypePickerView(selectedType: $viewModel.type)
                    .frame(width: AppSize.typePickerWidth, height: AppSize.typePickerHeight)

                Spacer()
            }

            HStack {
                closeButton

                Spacer()
            }
        }
        .frame(height: AppSize.screenHeader)
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.small)
        .padding(.top, AppSpacing.small)
        .background(AppColor.background)
        // Контент, уехавший под шапку, отделяется линией — иначе он «прилипает» к переключателю
        .overlay(alignment: .bottom) {
            Divider()
                .opacity(isContentScrolled ? 1 : 0)
                .animation(.easeOut(duration: 0.15), value: isContentScrolled)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(viewModel.screenTitle)
    }

    var closeButton: some View {
        ToolbarIconButton(icon: "xmark", isOutlined: true, action: handleClose)
            .padding(.leading, AppSpacing.medium)
            .fixedSize()
            .accessibilityLabel(AppString.accessibilityClose)
    }

    @ViewBuilder
    var form: some View {
        if #available(iOS 18.0, *) {
            formContent
                .onScrollGeometryChange(for: Bool.self) { geometry in
                    geometry.contentOffset.y > geometry.contentInsets.top
                } action: { _, isScrolled in
                    isContentScrolled = isScrolled
                }
        } else {
            formContent
        }
    }

    var formContent: some View {
        ScrollView {
            VStack(spacing: AppSpacing.large) {
                TransactionAmountView(
                    amount: viewModel.amountDisplay,
                    hasInput: viewModel.hasAmountInput
                )

                HStack(spacing: AppSpacing.medium) {
                    AccountPickerView(
                        account: viewModel.selectedAccount,
                        predictedBalance: viewModel.predictedBalance
                    ) {
                        isNoteFocused = false
                        showingAccountPicker = true
                    }

                    DateSelectionView(date: $viewModel.date) {
                        isNoteFocused = false
                    }
                }
                .frame(height: AppSize.inlineTile)

                CategorySelectionView(
                    categories: filteredCategories,
                    type: viewModel.type,
                    selectedCategory: $viewModel.selectedCategory
                )
                .card(cornerRadius: AppRadius.card)
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.type)

                NoteInputView(note: $viewModel.note, isFocused: $isNoteFocused)
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.top, AppSpacing.mediumSmall)
            .padding(.bottom, AppSpacing.small)
            .frame(maxWidth: .infinity, alignment: .top)
            // Тап по любому свободному месту формы убирает клавиатуру заметки
            .contentShape(Rectangle())
            .onTapGesture { isNoteFocused = false }
        }
        .scrollDismissesKeyboard(.interactively)
        .scrollBounceBehavior(.basedOnSize)
    }

    var keypad: some View {
        NumericKeypadView(
            isEnterEnabled: viewModel.isSaveEnabled,
            enterTitle: viewModel.saveButtonTitle,
            disabledHint: viewModel.validationHint,
            onKeyTap: viewModel.handleKeyTap,
            onClearTap: viewModel.clearAmount,
            onEnterTap: handleSave
        )
        .padding(.horizontal, AppSpacing.large)
        .padding(.bottom, AppSpacing.small)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    var accountSelectionSheet: some View {
        AccountSelectionSheet(
            accounts: accounts,
            selectedAccount: viewModel.selectedAccount,
            onSelect: { account in
                viewModel.selectedAccount = account
                showingAccountPicker = false
            },
            onShowAll: {
                showingAccountPicker = false
            },
            allowsAllAccounts: false
        )
    }
}

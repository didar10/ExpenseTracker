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

    @State private var showingAccountPicker = false

    @Query(sort: \Category.name)
    private var categories: [Category]

    @Query(sort: \Account.createdAt, order: .forward)
    private var accounts: [Account]

    // MARK: - Init

    init(transaction: Transaction? = nil) {
        _viewModel = StateObject(
            wrappedValue: AddTransactionViewModel(transaction: transaction)
        )
    }

    // MARK: - Computed Properties

    private var filteredCategories: [Category] {
        categories.filter { $0.type == viewModel.type }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {

                    header

                    ScrollView {
                        VStack(spacing: 14) {

                            TransactionAmountView(amount: viewModel.amount)

                            HStack(spacing: 20) {
                                AccountPickerView(
                                    selectedAccount: $viewModel.selectedAccount,
                                    transactionAmount: viewModel.pendingAmount,
                                    transactionType: viewModel.type,
                                    showingAccountPicker: $showingAccountPicker
                                )

                                DateSelectionView(date: $viewModel.date)
                            }
                            .frame(height: 60)

                            CategorySelectionView(
                                categories: filteredCategories,
                                type: viewModel.type,
                                selectedCategory: $viewModel.selectedCategory
                            )
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                                    .fill(AppColor.cardBackground)
                            )
                            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: viewModel.type)

                            NoteInputView(note: $viewModel.note)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, alignment: .top)
                    }
                    .scrollDismissesKeyboard(.interactively)

                    NumericKeypadView(
                        isEnterEnabled: viewModel.isSaveEnabled,
                        onKeyTap: viewModel.handleKeyTap,
                        onEnterTap: handleSave
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }

                if viewModel.showSuccessAnimation {
                    SuccessOverlayView(isShowing: viewModel.showSuccessAnimation)
                }
            }
            .background(AppColor.background)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(AppString.done) {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
                    }
                }
            }
            .onChange(of: viewModel.type) {
                if viewModel.selectedCategory?.type != viewModel.type {
                    viewModel.selectedCategory = nil
                }
            }
            .sheet(isPresented: $showingAccountPicker) {
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
    }
}

// MARK: - Actions
private extension AddTransactionView {

    func handleSave() {
        guard viewModel.save(using: modelContext) else { return }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            viewModel.showSuccessAndDismiss {
                dismiss()
            }
        }
    }
}

// MARK: - Subviews
private extension AddTransactionView {

    var header: some View {
        VStack(spacing: 8) {
            headerContent
        }
        .padding(.vertical, 8)
        .padding(.top, AppSpacing.medium)
        .background(AppColor.background)
        .frame(maxWidth: .infinity)
    }

    var headerContent: some View {
        ZStack {
            HStack {
                Spacer()
                TransactionTypePickerView(selectedType: $viewModel.type)
                    .frame(width: 220, height: 34)
                Spacer()
            }

            HStack {
                closeButton
                Spacer()
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
    }

    var closeButton: some View {
        ToolbarIconButton(icon: "xmark", isOutlined: true) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            dismiss()
        }
        .padding(.leading, 12)
        .fixedSize()
    }
}

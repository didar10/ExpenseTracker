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
                                    transactionAmount: viewModel.amount,
                                    transactionType: viewModel.type,
                                    showingAccountPicker: $showingAccountPicker
                                )

                                DateSelectionView(date: $viewModel.date)
                            }
                            .frame(height: 60)

                            Group {
                                if viewModel.type == .expense {
                                    CategorySelectionView(
                                        categories: categories,
                                        selectedCategory: $viewModel.selectedCategory
                                    )
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .trailing).combined(with: .opacity)
                                    ))
                                }
                            }
                            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: viewModel.type)

                            NoteInputView(note: $viewModel.note)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, alignment: .top)
                    }

                    Divider()
                        .padding(.bottom, 8)

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
            .sheet(isPresented: $showingAccountPicker) {
                AccountPickerSheet(
                    selectedAccount: $viewModel.selectedAccount,
                    accounts: accounts
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
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            dismiss()
        } label: {
            ZStack {
                Circle()
                    .fill(AppColor.secondaryBackground)
                    .frame(width: 34, height: 34)
                AppImage.close
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
            }
        }
        .padding(.leading, 12)
        .fixedSize()
    }
}

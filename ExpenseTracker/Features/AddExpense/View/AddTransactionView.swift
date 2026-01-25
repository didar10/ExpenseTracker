//
//  AddTransactionView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI
import SwiftData

struct AddTransactionView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: AddTransactionViewModel

    @Query(sort: \Category.name)
    private var categories: [Category]

    init(transaction: Transaction? = nil) {
        _viewModel = StateObject(
            wrappedValue: AddTransactionViewModel(transaction: transaction)
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    
                    header
                    
                    ScrollView {
                        VStack(spacing: 14) {
                            
                            TransactionAmountView(amount: viewModel.amount)
                            
                            // Выбор счета
                            AccountPickerView(
                                selectedAccount: $viewModel.selectedAccount,
                                transactionAmount: viewModel.amount,
                                transactionType: viewModel.type
                            )

                            // Выбор категории (только для расходов)
                            Group {
                                if viewModel.type == .expense {
                                    CategorySelectionView(
                                        categories: categories,
                                        selectedCategory: $viewModel.selectedCategory,
                                        onShowAll: {
                                            viewModel.toggleShowAllCategories()
                                        }
                                    )
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .trailing).combined(with: .opacity)
                                    ))
                                }
                            }
                            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: viewModel.type)

                            TransactionDetailsView(
                                date: $viewModel.date,
                                note: $viewModel.note
                            )
                        }
                        .padding(.horizontal) // Общий padding для всех элементов
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, alignment: .top) // Фиксируем ширину
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
                
                // Success overlay
                if viewModel.showSuccessAnimation {
                    SuccessOverlayView(isShowing: viewModel.showSuccessAnimation)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationDestination(isPresented: $viewModel.showAllCategories) {
                AllCategoriesView(
                    categories: categories,
                    selectedCategory: viewModel.selectedCategory,
                    onSelect: { category in
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            viewModel.selectCategory(category)
                        }
                        viewModel.showAllCategories = false
                    }
                )
            }
        }
    }
    
    private func handleSave() {
        guard viewModel.save(using: modelContext) else { return }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            viewModel.showSuccessAndDismiss {
                dismiss()
            }
        }
    }
}

// MARK: - Header

private extension AddTransactionView {

    var header: some View {
        VStack(spacing: 8) {
            headerContent
        }
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
        .frame(maxWidth: .infinity) // Фиксируем ширину
    }
    
    var headerContent: some View {
        ZStack {
            // Centered typePicker
            HStack {
                Spacer()
                TransactionTypePickerView(selectedType: $viewModel.type)
                    .frame(width: 220, height: 34)
                Spacer()
            }
            
            // Close button on the left
            HStack {
                closeButton
                Spacer()
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity) // Фиксируем ширину
    }
    
    var closeButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            dismiss()
        } label: {
            ZStack {
                Circle()
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(width: 34, height: 34)
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
            }
        }
        .padding(.leading, 12)
        .fixedSize() // Фиксируем размер кнопки
    }
}


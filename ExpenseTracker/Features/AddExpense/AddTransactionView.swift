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

    // UI state
    @State private var highlightedCategory: Category?
    @State private var showSuccessAnimation = false
    @State private var showAllCategories = false
    @Namespace private var animation

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
                            typePicker
                                .padding(.horizontal)
                            
                            amountView
                                .padding(.horizontal)

                            if viewModel.type == .expense {
                                categoriesScroll
                                    .padding(.horizontal)
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                            }

                            details
                                .padding(.horizontal)
                        }
                        .padding(.top, 10)
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
                if showSuccessAnimation {
                    successOverlay
                }
            }
            .background(Color(.systemGroupedBackground))
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.type)
            .navigationDestination(isPresented: $showAllCategories) {
                AllCategoriesView(
                    categories: categories,
                    selectedCategory: viewModel.selectedCategory,
                    onSelect: { category in
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            viewModel.selectedCategory = category
                        }
                        showAllCategories = false
                    }
                )
            }
        }
    }
    
    private func handleSave() {
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        viewModel.save(using: modelContext)
        
        // Show success animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showSuccessAnimation = true
        }
        
        // Dismiss after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            dismiss()
        }
    }
}

private extension AddTransactionView {

    var header: some View {
        HStack {
            Text(viewModel.isEditing ? "Редактировать" : "Новая транзакция")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.primary)

            Spacer()

            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.tertiary)
                    .symbolRenderingMode(.hierarchical)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, value: showSuccessAnimation)
                
                Text("Сохранено!")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .padding(32)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            }
            .scaleEffect(showSuccessAnimation ? 1.0 : 0.5)
            .opacity(showSuccessAnimation ? 1.0 : 0)
        }
    }
}

private extension AddTransactionView {

    var typePicker: some View {
        HStack(spacing: 0) {
            ForEach([TransactionType.expense, TransactionType.income], id: \.self) { type in
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.type = type
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: type == .expense ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(viewModel.type == type ? .white : (type == .expense ? .red : .green))
                        
                        Text(type == .expense ? "Расход" : "Доход")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(viewModel.type == type ? .white : .primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(viewModel.type == type ? 
                                  (type == .expense ? Color.red : Color.green) : 
                                  Color(.secondarySystemGroupedBackground))
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
    }
}

private extension AddTransactionView {

    var amountView: some View {
        HStack(spacing: 4) {
            Text(viewModel.type == .expense ? "−" : "+")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(viewModel.type == .expense ? .red : .green)
            
            Text(viewModel.amount.isEmpty ? "0" : viewModel.amount)
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            Text("₸")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
        .contentTransition(.numericText())
    }
}

private extension AddTransactionView {

    var categoriesScroll: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                // Первые 4 категории
                ForEach(Array(categories.prefix(4))) { category in
                    categoryItem(category)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                viewModel.selectedCategory = category
                            }
                        }
                }
                
                // Кнопка "Ещё"
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showAllCategories = true
                } label: {
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(Color(.secondarySystemGroupedBackground))
                                .frame(width: Constants.categoryIconSize, height: Constants.categoryIconSize)

                            Image(systemName: "ellipsis")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        
                        Text("Ещё")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
    }

    func categoryItem(_ category: Category) -> some View {
        let isSelected = viewModel.selectedCategory?.id == category.id

        return VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color(hex: category.colorHex) : Color(.secondarySystemGroupedBackground))
                    .frame(width: Constants.categoryIconSize, height: Constants.categoryIconSize)
                    .shadow(
                        color: isSelected ? Color(hex: category.colorHex).opacity(0.3) : .clear,
                        radius: isSelected ? 6 : 0,
                        y: isSelected ? 3 : 0
                    )

                Image(systemName: category.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : .secondary)
                    .symbolEffect(.bounce, value: isSelected)
            }
            
            Text(category.name)
                .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .frame(height: 28)
        }
        .frame(maxWidth: .infinity)
    }
}

private extension AddTransactionView {

    var details: some View {
        VStack(spacing: 12) {
            // Date Picker
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 18))
                
                DatePicker("Дата", selection: $viewModel.date, displayedComponents: .date)
                    .datePickerStyle(.compact)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            }

            // Note Field
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "text.alignleft")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 18))
                    .padding(.top, 10)
                
                TextField("Добавить комментарий...", text: $viewModel.note, axis: .vertical)
                    .lineLimit(3...5)
                    .padding(.vertical, 10)
            }
            .padding(.horizontal)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            }
        }
    }
}

// MARK: - All Categories View

struct AllCategoriesView: View {
    let categories: [Category]
    let selectedCategory: Category?
    let onSelect: (Category) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(categories) { category in
                    categoryItem(category)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            onSelect(category)
                        }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Все категории")
        .navigationBarTitleDisplayMode(.large)
    }
    
    @ViewBuilder
    func categoryItem(_ category: Category) -> some View {
        let isSelected = selectedCategory?.id == category.id
        
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color(hex: category.colorHex) : Color(.secondarySystemGroupedBackground))
                    .frame(width: 56, height: 56)
                    .shadow(
                        color: isSelected ? Color(hex: category.colorHex).opacity(0.3) : .clear,
                        radius: isSelected ? 6 : 0,
                        y: isSelected ? 3 : 0
                    )

                Image(systemName: category.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : .secondary)
                    .symbolEffect(.bounce, value: isSelected)
            }
            
            Text(category.name)
                .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .frame(height: 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        }
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Constants

private enum Constants {
    static let categoryIconSize: CGFloat = 48
}

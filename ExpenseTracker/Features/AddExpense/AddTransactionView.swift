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
//            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.type)
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
        VStack(spacing: 8) {
            ZStack {
                // Centered typePicker with fixed size
                typePicker
                    .frame(width: 220, height: 34)
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 50)
            // Fixed-position close button on the left
            .overlay(alignment: .leading) {
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
            }
            // Symmetric placeholder on the right to keep the center stable
            .overlay(alignment: .trailing) {
                Color.clear
                    .frame(width: 34, height: 34)
                    .padding(.trailing, 12)
            }
            .padding(.horizontal, 0)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
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
        HStack(spacing: 6) {
            // Expense button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.type = .expense
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.orange)
                    if viewModel.type == .expense {
                        Text("Расход")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.primary)
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(viewModel.type == .expense ? Color.orange.opacity(0.15) : .clear)
                )
            }
            .buttonStyle(.plain)

            // Income button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.type = .income
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.green)
                    if viewModel.type == .income {
                        Text("Доход")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.primary)
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(viewModel.type == .income ? Color.green.opacity(0.15) : .clear)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(6)
        .background(
            Capsule().fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

private extension AddTransactionView {

    var amountView: some View {
        VStack(spacing: 8) {
            // Removed the small type indicator row
            
            // Сумма
            HStack(spacing: 4) {
                // Removed the sign text indicating "-" or "+"
                
                Text(viewModel.amount.isEmpty ? "0" : viewModel.amount)
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                Text("₸")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .offset(y: -4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12) // from 24 to 12
//        .background {
//            RoundedRectangle(cornerRadius: 24, style: .continuous)
//                .fill(viewModel.type == .expense ?
//                      Color.red.opacity(0.08) :
//                      Color.green.opacity(0.08))
//        }
        .contentTransition(.numericText())
    }
}

private extension AddTransactionView {

    var categoriesScroll: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                ForEach(Array(categories.prefix(4))) { category in
                    categoryItem(category)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                viewModel.selectedCategory = category
                            }
                        }
                }
                // Circular "More" button styled like a category
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(.secondarySystemGroupedBackground))
                            .frame(width: 54, height: 54)
                        Image(systemName: "ellipsis")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    Text("Еще")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.center)
                        .frame(width: 64)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showAllCategories = true
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
        }
        .padding(.vertical, 4)
    }

    func categoryItem(_ category: Category) -> some View {
        let isSelected = viewModel.selectedCategory?.id == category.id

        return VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(hex: category.colorHex).opacity(isSelected ? 1.0 : 0.15))
                    .frame(width: 54, height: 54)
                    .overlay {
                        if isSelected {
                            Circle()
                                .strokeBorder(Color(hex: category.colorHex).opacity(0.3), lineWidth: 3)
                                .scaleEffect(1.15)
                        }
                    }

                Image(systemName: category.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : Color(hex: category.colorHex))
                    .symbolEffect(.bounce, value: isSelected)
            }
            
            Text(category.name)
                .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .lineLimit(2)
                .truncationMode(.tail)
                .multilineTextAlignment(.center)
                .frame(width: 64) // give a bit more width
        }
    }
}

private extension AddTransactionView {

    var details: some View {
        VStack(spacing: 16) {
            // Date Picker
            VStack(alignment: .leading, spacing: 8) {
//                Text("Дата")
//                    .font(.system(size: 13, weight: .semibold))
//                    .foregroundStyle(.secondary)
//                    .padding(.horizontal, 4)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 18))
                    
                    DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemBackground))
                }
            }

            // Note Field
            VStack(alignment: .leading, spacing: 8) {
//                Text("Комментарий")
//                    .font(.system(size: 13, weight: .semibold))
//                    .foregroundStyle(.secondary)
//                    .padding(.horizontal, 4)
                
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "text.alignleft")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 18))
                        .padding(.top, 14)
                    
                    TextField("Добавить комментарий...", text: $viewModel.note, axis: .vertical)
                        .lineLimit(2...4)
                        .padding(.vertical, 14)
                }
                .padding(.horizontal, 16)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemBackground))
                }
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


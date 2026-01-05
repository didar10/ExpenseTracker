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

    // 🔹 Только для UI (анимация / hover)
    @State private var highlightedCategory: Category?

    init(transaction: Transaction? = nil) {
        _viewModel = StateObject(
            wrappedValue: AddTransactionViewModel(transaction: transaction)
        )
    }

    var body: some View {
        VStack(spacing: 16) {

            header
            typePicker
            amountView

            if viewModel.type == .expense {
                categoriesScroll
            }

            details

            Spacer(minLength: 8)

            NumericKeypadView(
                isEnterEnabled: viewModel.isSaveEnabled,
                onKeyTap: viewModel.handleKeyTap,
                onEnterTap: {
                    viewModel.save(using: modelContext)
                    dismiss()
                }
            )
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
}

private extension AddTransactionView {

    var header: some View {
        HStack {
            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Circle())
            }
        }
    }
}

private extension AddTransactionView {

    var typePicker: some View {
        Picker("Тип", selection: $viewModel.type) {
            Text("Расход").tag(TransactionType.expense)
            Text("Доход").tag(TransactionType.income)
        }
        .pickerStyle(.segmented)
    }
}

private extension AddTransactionView {

    var amountView: some View {
        Text(viewModel.amount.isEmpty ? "0" : viewModel.amount)
            .font(.system(size: 42, weight: .bold))
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.vertical, 8)
    }
}

private extension AddTransactionView {

    var categoriesScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 14) {
                ForEach(categories) { category in
                    categoryItem(category)
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(height: 96)
    }

    func categoryItem(_ category: Category) -> some View {
        let isHighlighted = highlightedCategory?.id == category.id
        let isSelected = viewModel.selectedCategory?.id == category.id

        return VStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(isSelected ? .green : Color(.secondarySystemBackground))
                )

            Text(category.name)
                .font(.app(.caption))
                .lineLimit(1)
        }
        .padding(8)
        .scaleEffect(isHighlighted ? 1.18 : 1.0)
        .animation(
            .spring(response: 0.35, dampingFraction: 0.65),
            value: isHighlighted
        )
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()

            highlightedCategory = category
            viewModel.selectedCategory = category
        }
    }
}

private extension AddTransactionView {

    var details: some View {
        VStack(spacing: 12) {
            DatePicker("Дата", selection: $viewModel.date, displayedComponents: .date)

            TextField("Комментарий", text: $viewModel.note)
                .textFieldStyle(.roundedBorder)
        }
    }
}

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
        VStack(spacing: 24) {

            typePicker
            amountInput

            if viewModel.type == .expense {
                categoriesGrid
            }

            details

            Spacer()

            saveButton
        }
        .padding()
        .navigationTitle(viewModel.isEditing ? "Редактировать" : "Новая транзакция")
    }
}

// MARK: - UI
private extension AddTransactionView {

    var typePicker: some View {
        Picker("Тип", selection: $viewModel.type) {
            Text("Расход").tag(TransactionType.expense)
            Text("Доход").tag(TransactionType.income)
        }
        .pickerStyle(.segmented)
    }

    var amountInput: some View {
        TextField("0", text: $viewModel.amount)
            .font(.system(size: 40, weight: .bold))
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
    }

    var categoriesGrid: some View {
        LazyVGrid(
            columns: Array(repeating: .init(.flexible()), count: 4),
            spacing: 12
        ) {
            ForEach(categories) { category in
                CategoryItemView(
                    category: category,
                    isSelected: viewModel.selectedCategory == category
                )
                .onTapGesture {
                    viewModel.selectedCategory = category
                }
            }
        }
    }

    var details: some View {
        VStack(spacing: 12) {
            DatePicker("Дата", selection: $viewModel.date, displayedComponents: .date)

            TextField("Комментарий", text: $viewModel.note)
                .textFieldStyle(.roundedBorder)
        }
    }

    var saveButton: some View {
        Button {
            viewModel.save(using: modelContext)
            dismiss()
        } label: {
            Text(viewModel.isEditing ? "Сохранить" : "Добавить")
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isSaveEnabled ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(!viewModel.isSaveEnabled)
    }
}

//
//  AddExpenseView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import Foundation
import SwiftUI
import SwiftData

struct AddExpenseView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel = AddExpenseViewModel()

    @Query(sort: \Category.name)
    private var categories: [Category]

    var body: some View {
        VStack(spacing: 24) {

            amountInput
            categoriesGrid
            details

            Spacer()

            saveButton
        }
        .padding()
        .navigationTitle("Новый расход")
    }
}


private extension AddExpenseView {

    var amountInput: some View {
        TextField("0", text: $viewModel.amount)
            .font(.system(size: 40, weight: .bold))
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
    }

    var categoriesGrid: some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4)) {
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
            Text("Добавить")
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isSaveEnabled ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(!viewModel.isSaveEnabled)
    }
}

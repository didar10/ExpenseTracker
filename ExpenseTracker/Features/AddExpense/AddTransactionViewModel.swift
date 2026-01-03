//
//  AddTransactionViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI
import SwiftData

@MainActor
final class AddTransactionViewModel: ObservableObject {

    @Published var amount: String = ""
    @Published var selectedCategory: Category?
    @Published var note: String = ""
    @Published var date: Date = .now
    @Published var type: TransactionType = .expense

    private(set) var editingTransaction: Transaction?

    init(transaction: Transaction? = nil) {
        self.editingTransaction = transaction

        guard let transaction else { return }

        amount = transaction.amount.description
        selectedCategory = transaction.category
        note = transaction.note ?? ""
        date = transaction.date
        type = transaction.type
    }

    var isEditing: Bool {
        editingTransaction != nil
    }

    var isSaveEnabled: Bool {
        Decimal(string: amount) != nil && selectedCategory != nil
    }

    func save(using context: ModelContext) {
        guard
            let value = Decimal(string: amount),
            let category = selectedCategory
        else { return }

        if let transaction = editingTransaction {
            // ✏️ EDIT
            transaction.amount = value
            transaction.category = category
            transaction.note = note.isEmpty ? nil : note
            transaction.date = date
            transaction.type = type
        } else {
            // ➕ CREATE
            let newTransaction = Transaction(
                amount: value,
                date: date,
                note: note.isEmpty ? nil : note,
                type: type,
                category: category
            )
            context.insert(newTransaction)
        }
    }
}

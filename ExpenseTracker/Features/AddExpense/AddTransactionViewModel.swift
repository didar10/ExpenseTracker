//
//  AddTransactionViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import Foundation
import SwiftData

@MainActor
final class AddTransactionViewModel: ObservableObject {

    // MARK: - Input
    @Published var amount: String = ""
    @Published var selectedCategory: Category?
    @Published var note: String = ""
    @Published var date: Date = .now
    @Published var type: TransactionType = .expense

    private(set) var editingTransaction: Transaction?

    // MARK: - Init
    init(transaction: Transaction? = nil) {
        self.editingTransaction = transaction

        guard let transaction else { return }

        amount = transaction.amount.description
        selectedCategory = transaction.category
        note = transaction.note ?? ""
        date = transaction.date
        type = transaction.type
    }

    // MARK: - State
    var isEditing: Bool {
        editingTransaction != nil
    }

    var isSaveEnabled: Bool {
        Decimal(string: amount) != nil &&
        (type == .income || selectedCategory != nil)
    }

    var amountDisplay: String {
        amount.isEmpty ? "0" : amount
    }

    private var amountDecimal: Decimal? {
        Decimal(string: amount.replacingOccurrences(of: ",", with: "."))
    }

    // MARK: - Save
    func save(using context: ModelContext) {
        guard let value = amountDecimal else { return }

        if let transaction = editingTransaction {
            transaction.amount = value
            transaction.category = type == .expense ? selectedCategory : nil
            transaction.note = note.isEmpty ? nil : note
            transaction.date = date
            transaction.type = type
        } else {
            let newTransaction = Transaction(
                amount: value,
                date: date,
                note: note.isEmpty ? nil : note,
                type: type,
                category: type == .expense ? selectedCategory : nil
            )
            context.insert(newTransaction)
        }
    }

    // MARK: - Keypad logic
    func handleKeyTap(_ key: NumericKeypadView.Key) {
        switch key {
        case .number(let value):
            appendNumber(value)
        case .decimal:
            appendDecimal()
        case .delete:
            deleteLast()
        }
    }

    private func appendNumber(_ value: String) {
        if amount == "0" {
            amount = value
        } else {
            amount.append(value)
        }
    }

    private func appendDecimal() {
        guard !amount.contains(".") else { return }
        amount = amount.isEmpty ? "0." : amount + "."
    }

    private func deleteLast() {
        guard !amount.isEmpty else { return }
        amount.removeLast()
    }
}

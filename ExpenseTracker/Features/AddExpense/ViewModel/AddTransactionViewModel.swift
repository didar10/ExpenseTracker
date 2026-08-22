//
//  AddTransactionViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import Foundation
import SwiftData
import UIKit

@MainActor
final class AddTransactionViewModel: ObservableObject {

    // MARK: - Input Data

    @Published var amount: String = ""
    @Published var selectedCategory: Category?
    @Published var selectedAccount: Account?
    @Published var note: String = ""
    @Published var date: Date = .now
    @Published var type: TransactionType = .expense

    // MARK: - UI State

    @Published var showSuccessAnimation = false
    @Published var showAllCategories = false
    /// Транзакция уже записана в контекст: защищает от повторного сохранения
    @Published private(set) var isSaved = false

    private(set) var editingTransaction: Transaction?

    // MARK: - Init

    init(transaction: Transaction? = nil) {
        self.editingTransaction = transaction

        guard let transaction else { return }

        amount = transaction.amount.description
        selectedCategory = transaction.category
        selectedAccount = transaction.account
        note = transaction.note ?? ""
        date = transaction.date
        type = transaction.type
    }

    // MARK: - Computed Properties
    var isEditing: Bool {
        editingTransaction != nil
    }

    var isSaveEnabled: Bool {
        !isSaved &&
        Decimal(string: amount) != nil &&
        selectedAccount != nil
    }

    /// Сумма для предпросмотра баланса счёта: после сохранения транзакция
    /// уже учтена в `currentBalance`, поэтому вычитать её повторно нельзя
    var pendingAmount: String {
        isSaved ? "" : amount
    }

    var amountDisplay: String {
        amount.isEmpty ? "0" : amount
    }

    private var amountDecimal: Decimal? {
        Decimal(string: amount.replacingOccurrences(of: ",", with: "."))
    }

    // MARK: - Actions
    
    func selectCategory(_ category: Category) {
        selectedCategory = category
        provideFeedback(.medium)
    }
    
    func toggleShowAllCategories() {
        showAllCategories.toggle()
        provideFeedback(.light)
    }
    
    func changeType(to type: TransactionType) {
        self.type = type
        provideFeedback(.medium)
    }
    
    // MARK: - Save
    func save(using context: ModelContext) -> Bool {
        guard !isSaved, let value = amountDecimal else { return false }
        
        provideFeedback(.medium)

        if let transaction = editingTransaction {
            transaction.amount = value
            transaction.category = selectedCategory
            transaction.account = selectedAccount
            transaction.note = note.isEmpty ? nil : note
            transaction.date = date
            transaction.type = type
        } else {
            let newTransaction = Transaction(
                amount: value,
                date: date,
                note: note.isEmpty ? nil : note,
                type: type,
                category: selectedCategory,
                account: selectedAccount
            )
            context.insert(newTransaction)
        }

        isSaved = true

        return true
    }
    
    func showSuccessAndDismiss(onDismiss: @escaping () -> Void) {
        showSuccessAnimation = true
        
        Task {
            try? await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
            onDismiss()
        }
    }

    // MARK: - Keypad Logic
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
    
    // MARK: - Haptic Feedback
    private func provideFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

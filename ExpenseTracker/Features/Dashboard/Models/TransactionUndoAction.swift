//
//  TransactionUndoAction.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation

/// Последнее действие над операцией, которое можно отменить из тоста
struct TransactionUndoAction: Identifiable {

    enum Kind {
        /// Удаленная операция хранится копией полей: сама модель после удаления недействительна
        case deleted(TransactionDraft)
        /// Созданный повтор: отмена удаляет его
        case repeated(Transaction)
    }

    // MARK: - Properties

    let id = UUID()
    let kind: Kind

    // MARK: - Computed Properties

    var message: String {
        switch kind {
        case .deleted: return AppString.transactionDeleted
        case .repeated: return AppString.transactionRepeated
        }
    }
}

/// Поля операции без привязки к контексту — чтобы восстановить ее после удаления
struct TransactionDraft {

    // MARK: - Properties

    let amount: Decimal
    let date: Date
    let note: String?
    let type: TransactionType
    let category: Category?
    let account: Account?

    // MARK: - Init

    init(_ transaction: Transaction) {
        amount = transaction.amount
        date = transaction.date
        note = transaction.note
        type = transaction.type
        category = transaction.category
        account = transaction.account
    }

    // MARK: - Methods

    func makeTransaction(date: Date? = nil) -> Transaction {
        Transaction(
            amount: amount,
            date: date ?? self.date,
            note: note,
            type: type,
            category: category,
            account: account
        )
    }
}

//
//  TransactionDraft.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation

/// Поля операции без привязки к контексту: из них репозиторий создает
/// или обновляет операцию, ими же восстанавливается удаленная
struct TransactionDraft {

    // MARK: - Properties

    var amount: Decimal
    var date: Date
    var note: String?
    var type: TransactionType
    var category: Category?
    var account: Account?

    // MARK: - Init

    init(
        amount: Decimal,
        date: Date,
        note: String? = nil,
        type: TransactionType,
        category: Category? = nil,
        account: Account? = nil
    ) {
        self.amount = amount
        self.date = date
        self.note = note
        self.type = type
        self.category = category
        self.account = account
    }

    init(_ transaction: Transaction) {
        self.init(
            amount: transaction.amount,
            date: transaction.date,
            note: transaction.note,
            type: transaction.type,
            category: transaction.category,
            account: transaction.account
        )
    }

    // MARK: - Methods

    func makeTransaction() -> Transaction {
        Transaction(
            amount: amount,
            date: date,
            note: note,
            type: type,
            category: category,
            account: account
        )
    }

    /// Применяет поля к существующей операции
    func apply(to transaction: Transaction) {
        transaction.amount = amount
        transaction.date = date
        transaction.note = note
        transaction.type = type
        transaction.category = category
        transaction.account = account
    }
}

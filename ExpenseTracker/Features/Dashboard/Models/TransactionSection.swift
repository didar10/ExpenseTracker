//
//  TransactionSection.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import Foundation

/// Операции одного дня для ленты главной
struct TransactionSection: Identifiable {

    // MARK: - Properties

    let id: Date
    let date: Date
    let transactions: [Transaction]

    // MARK: - Computed Properties

    /// Итог дня: доходы минус расходы — «+473 050» в заголовке дня
    var total: Decimal {
        transactions.reduce(into: Decimal.zero) { total, transaction in
            total += transaction.type == .income ? transaction.amount : -transaction.amount
        }
    }

    // MARK: - Init

    init(date: Date, transactions: [Transaction]) {
        self.id = date
        self.date = date
        self.transactions = transactions
    }

    // MARK: - Methods

    /// Группирует операции по дням, новые дни — выше
    static func group(_ transactions: [Transaction], calendar: Calendar = .current) -> [TransactionSection] {
        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }

        return grouped
            .map { TransactionSection(date: $0.key, transactions: $0.value) }
            .sorted { $0.date > $1.date }
    }
}

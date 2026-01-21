//
//  TransactionSection.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import Foundation

/// Модель для группировки транзакций по датам
struct TransactionSection: Identifiable {
    let id: Date
    let date: Date
    let transactions: [Transaction]
    
    init(date: Date, transactions: [Transaction]) {
        self.id = date
        self.date = date
        self.transactions = transactions
    }
    
    /// Группирует транзакции по дням
    static func group(_ transactions: [Transaction]) -> [TransactionSection] {
        let grouped = Dictionary(grouping: transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
        
        return grouped
            .map { TransactionSection(date: $0.key, transactions: $0.value) }
            .sorted { $0.date > $1.date }
    }
}

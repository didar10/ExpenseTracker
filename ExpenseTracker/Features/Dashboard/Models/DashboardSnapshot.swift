//
//  DashboardSnapshot.swift
//  ExpenseTracker
//
//  Created by Didar on 01.09.2026.
//

import Foundation

/// Всё, что главный экран показывает за один проход по операциям:
/// баланс периода, общий баланс счетов для шапки и сгруппированный список
struct DashboardSnapshot {

    // MARK: - Properties

    /// Баланс за выбранный период — крупное число на экране
    let periodBalance: BalanceData
    /// Баланс счетов за все время — маленькая подпись в шапке
    let totalBalance: Decimal
    let sections: [TransactionSection]

    // MARK: - Computed Properties

    var isEmpty: Bool {
        sections.isEmpty
    }

    // MARK: - Init

    static let empty = DashboardSnapshot(
        periodBalance: BalanceData(transactions: []),
        totalBalance: 0,
        sections: []
    )
}

//
//  AccessibilityID.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation

/// Идентификаторы элементов для UI-тестов: не зависят от языка интерфейса
enum AccessibilityID {
    static let categoryTransactionsBack = "categoryTransactions.back"
    static let categoryTransactionsSummary = "categoryTransactions.summary"
    static let accountFormSave = "accountForm.save"
    static let accountSelectionAdd = "accountSelection.add"
    static let dailyAllowanceCard = "dashboard.dailyAllowanceCard"
    static let monthlyLimitAmount = "monthlyLimit.amount"
}

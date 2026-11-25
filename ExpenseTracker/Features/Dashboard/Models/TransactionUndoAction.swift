//
//  TransactionUndoAction.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation

/// Удаленная операция, которую можно вернуть из тоста «Отменить»
struct TransactionUndoAction: Identifiable {

    // MARK: - Properties

    let id = UUID()
    /// Копия полей: сама модель после удаления недействительна
    let draft: TransactionDraft

    // MARK: - Computed Properties

    var message: String {
        AppString.transactionDeleted
    }
}

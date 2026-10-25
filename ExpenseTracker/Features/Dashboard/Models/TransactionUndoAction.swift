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

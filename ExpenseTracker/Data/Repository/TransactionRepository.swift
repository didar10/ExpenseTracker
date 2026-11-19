//
//  TransactionRepository.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation
import SwiftData

/// Запись операций. Каждый метод сразу сохраняет изменения на диск,
/// а при ошибке откатывает их и пробрасывает ошибку экрану
@MainActor
protocol TransactionRepository {
    @discardableResult
    func add(_ draft: TransactionDraft) throws -> Transaction
    func update(_ transaction: Transaction, with draft: TransactionDraft) throws
    func delete(_ transaction: Transaction) throws
}

@MainActor
struct SwiftDataTransactionRepository: TransactionRepository {

    // MARK: - Properties

    let context: ModelContext

    // MARK: - Methods

    @discardableResult
    func add(_ draft: TransactionDraft) throws -> Transaction {
        let transaction = draft.makeTransaction()
        context.insert(transaction)
        try context.saveOrRollback()
        return transaction
    }

    func update(_ transaction: Transaction, with draft: TransactionDraft) throws {
        let previous = TransactionDraft(transaction)
        draft.apply(to: transaction)

        do {
            try context.saveOrRollback()
        } catch {
            // Иначе экран показывал бы правку, которой нет в базе
            previous.apply(to: transaction)
            throw error
        }
    }

    func delete(_ transaction: Transaction) throws {
        context.delete(transaction)
        try context.saveOrRollback()
    }
}

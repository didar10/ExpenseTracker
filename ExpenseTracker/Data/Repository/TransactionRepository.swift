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
        try validateTransferAccounts(in: draft)
        let transaction = try Transaction(validating: draft)
        context.insert(transaction)
        try context.saveOrRollback()
        return transaction
    }

    func update(_ transaction: Transaction, with draft: TransactionDraft) throws {
        try validateTransferAccounts(in: draft)
        let previous = TransactionDraft(transaction)
        try transaction.apply(draft)

        do {
            try context.saveOrRollback()
        } catch {
            // Иначе экран показывал бы правку, которой нет в базе
            try transaction.apply(previous)
            throw error
        }
    }

    private func validateTransferAccounts(in draft: TransactionDraft) throws {
        guard draft.kind == .transfer else { return }
        guard draft.fromAccount?.modelContext === context, draft.toAccount?.modelContext === context else {
            throw TransferValidationError.unavailableAccount
        }
    }

    func delete(_ transaction: Transaction) throws {
        context.delete(transaction)
        try context.saveOrRollback()
    }
}

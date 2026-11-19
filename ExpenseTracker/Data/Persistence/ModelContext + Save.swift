//
//  ModelContext + Save.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation
import OSLog
import SwiftData

extension ModelContext {

    /// Сохраняет изменения на диск сразу, не дожидаясь автосохранения:
    /// иначе операция, добавленная перед закрытием приложения, может пропасть.
    ///
    /// При ошибке откатывает несохраненные изменения и пробрасывает ошибку, чтобы экран о ней сообщил.
    /// Откат отменяет вставки и удаления, но уже загруженные модели продолжают показывать
    /// измененные поля — их возвращает к прежним значениям вызывающий код (репозиторий)
    func saveOrRollback() throws {
        guard hasChanges else { return }

        do {
            try save()
        } catch {
            rollback()
            PersistenceLog.logger.error("Не удалось сохранить данные: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }
}

enum PersistenceLog {
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ExpenseTracker", category: "Persistence")
}

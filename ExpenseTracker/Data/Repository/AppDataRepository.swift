//
//  AppDataRepository.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation
import SwiftData

/// Операции над всей базой: начальные данные и полная очистка
@MainActor
protocol AppDataRepository {
    func seedDefaultsIfNeeded()
    /// Удаляет все пользовательские данные и заново создает значения по умолчанию
    func deleteAllData() throws
}

@MainActor
struct SwiftDataAppDataRepository: AppDataRepository {

    // MARK: - Properties

    let context: ModelContext

    // MARK: - Methods

    func seedDefaultsIfNeeded() {
        CategorySeeder.seedIfNeeded(context: context)
        AccountSeeder.seedIfNeeded(context: context)
    }

    func deleteAllData() throws {
        // Удаление по одной записи, а не пакетом: пакетное удаление идет мимо
        // правил связей и не обновляет уже загруженные модели
        try deleteAll(BudgetPlan.self)
        try deleteAll(Transaction.self)
        try deleteAll(Category.self)
        try deleteAll(Account.self)

        try context.saveOrRollback()

        // Сидеры создают данные только на пустой базе, поэтому нужен save выше
        seedDefaultsIfNeeded()
    }

    // MARK: - Private Methods

    private func deleteAll<Model: PersistentModel>(_ type: Model.Type) throws {
        try context.fetch(FetchDescriptor<Model>()).forEach { context.delete($0) }
    }
}

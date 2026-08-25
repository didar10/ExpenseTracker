//
//  SettingsViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 23.08.2026.
//

import Foundation
import SwiftData

/// ViewModel экрана настроек
@MainActor
@Observable
final class SettingsViewModel {

    // MARK: - Properties

    var showingDeleteAllDataAlert = false

    // MARK: - Actions

    func prepareDeleteAllData() {
        showingDeleteAllDataAlert = true
    }

    func cancelDeleteAllData() {
        showingDeleteAllDataAlert = false
    }

    /// Удаляет все пользовательские данные и заново создает значения по умолчанию
    func confirmDeleteAllData(context: ModelContext) {
        // Бюджеты удаляются первыми: они ссылаются на категорию без опционала
        deleteAll(BudgetPlan.self, context: context)
        deleteAll(Transaction.self, context: context)
        deleteAll(Category.self, context: context)
        deleteAll(Account.self, context: context)

        try? context.save()

        // Сидеры создают данные только на пустой базе, поэтому нужен save выше
        CategorySeeder.seedIfNeeded(context: context)
        AccountSeeder.seedIfNeeded(context: context)

        try? context.save()

        showingDeleteAllDataAlert = false
    }

    // MARK: - Private Methods

    private func deleteAll<Model: PersistentModel>(_ type: Model.Type, context: ModelContext) {
        let descriptor = FetchDescriptor<Model>()

        guard let items = try? context.fetch(descriptor) else { return }

        items.forEach { context.delete($0) }
    }
}

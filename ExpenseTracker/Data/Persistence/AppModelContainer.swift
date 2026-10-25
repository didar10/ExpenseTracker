//
//  AppModelContainer.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation
import SwiftData

/// Единственное место, где создается хранилище данных: приложение и тесты
/// открывают базу одинаково — через текущую схему и план миграций
enum AppModelContainer {

    /// - Parameter url: файл базы. nil — файл по умолчанию, тот же, что был до появления миграций
    static func make(inMemory: Bool = false, url: URL? = nil) throws -> ModelContainer {
        let schema = Schema(versionedSchema: CurrentSchema.self)

        let configuration: ModelConfiguration
        if let url {
            configuration = ModelConfiguration(schema: schema, url: url)
        } else {
            // У in-memory базы свое имя: безымянная общая для всех контейнеров процесса,
            // и параллельные тесты видели бы чужие данные
            configuration = inMemory
                ? ModelConfiguration(UUID().uuidString, schema: schema, isStoredInMemoryOnly: true)
                : ModelConfiguration(schema: schema)
        }

        return try ModelContainer(
            for: schema,
            migrationPlan: AppMigrationPlan.self,
            configurations: configuration
        )
    }
}

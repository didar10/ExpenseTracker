//
//  AppMigrationPlan.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation
import SwiftData

/// Текущая версия схемы: ее открывает приложение и тесты
typealias CurrentSchema = SchemaV2

/// Все версии схемы по порядку и шаги перехода между ними.
/// Новая версия: добавить ее в `schemas`, шаг перехода — в `stages`,
/// перенаправить `CurrentSchema` и покрыть переход тестом в AppMigrationPlanTests
enum AppMigrationPlan: SchemaMigrationPlan {

    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    /// Добавились только обратные связи, а связь бюджета с категорией стала необязательной:
    /// данные не меняются, поэтому достаточно легкой миграции
    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: SchemaV1.self,
        toVersion: SchemaV2.self
    )
}

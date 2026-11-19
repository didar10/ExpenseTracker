//
//  SchemaV2.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation
import SwiftData

/// Вторая версия: у категории появились обратные связи с правилами удаления.
/// Удаленная категория обнуляется у операций и удаляет свои бюджеты сама —
/// без ручной чистки, а бюджет без категории больше не роняет SwiftData.
///
/// Последняя версия ссылается на модели из Data/Model. При следующем изменении
/// моделей скопируйте их текущий вид сюда как вложенные типы — так же, как в SchemaV1
enum SchemaV2: VersionedSchema {

    static let versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            Transaction.self,
            Category.self,
            Account.self,
            BudgetPlan.self
        ]
    }
}

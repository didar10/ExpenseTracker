import Foundation
import SwiftData

/// Приложение и тесты открывают одну и ту же текущую схему.
enum AppModelContainer {
    static func make(inMemory: Bool = false, url: URL? = nil) throws -> ModelContainer {
        let schema = Schema([Transaction.self, Category.self, Account.self, BudgetPlan.self])

        let configuration: ModelConfiguration
        if let url {
            configuration = ModelConfiguration(schema: schema, url: url)
        } else if inMemory {
            // У параллельных тестов отдельные базы в памяти.
            configuration = ModelConfiguration(UUID().uuidString, schema: schema, isStoredInMemoryOnly: true)
        } else {
            // Схема переводов открывает новый файл. Старая отладочная база остается на диске.
            configuration = ModelConfiguration("ExpenseTracker-Transfers", schema: schema)
        }

        return try ModelContainer(for: schema, configurations: configuration)
    }
}

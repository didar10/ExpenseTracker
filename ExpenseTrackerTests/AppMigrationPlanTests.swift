//
//  AppMigrationPlanTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 26.10.2026.
//

import Foundation
import SwiftData
import Testing
@testable import ExpenseTracker

@MainActor
struct AppMigrationPlanTests {

    // MARK: - Helpers

    private func makeStoreURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("AppMigrationPlanTests-\(UUID().uuidString)")
            .appendingPathExtension("store")
    }

    /// База так, как ее создавала версия приложения без миграций: модели V1, схема без версии
    private func seedLegacyStore(at url: URL) throws {
        let container = try ModelContainer(
            for: Schema(SchemaV1.models),
            configurations: ModelConfiguration(url: url)
        )
        let context = ModelContext(container)

        let account = SchemaV1.Account(name: "Основной", initialBalance: 1_000)
        let category = SchemaV1.Category(name: "Еда", icon: "fork.knife", colorHex: "#34C759")
        context.insert(account)
        context.insert(category)
        context.insert(
            SchemaV1.Transaction(amount: 250, date: .now, note: "Обед", type: .expense, category: category, account: account)
        )
        context.insert(SchemaV1.BudgetPlan(category: category, monthlyLimit: 50_000))

        try context.save()
    }

    // MARK: - Tests

    @Test func legacyStoreOpensWithMigrationPlanAndKeepsData() throws {
        let url = makeStoreURL()
        defer { try? FileManager.default.removeItem(at: url) }

        try seedLegacyStore(at: url)

        let container = try AppModelContainer.make(url: url)
        let context = ModelContext(container)

        let transactions = try context.fetch(FetchDescriptor<Transaction>())
        let accounts = try context.fetch(FetchDescriptor<Account>())
        let plans = try context.fetch(FetchDescriptor<BudgetPlan>())

        #expect(transactions.count == 1)
        #expect(transactions.first?.note == "Обед")
        #expect(transactions.first?.category?.name == "Еда")
        #expect(plans.first?.category?.name == "Еда")
        #expect(accounts.first?.currentBalance == 750)
        #expect(plans.first?.monthlyLimit == 50_000)
    }

    /// Связи, добавленные в V2, работают и для данных, созданных до миграции
    @Test func migratedCategoryDeletionNullifiesTransactionsAndRemovesBudgets() throws {
        let url = makeStoreURL()
        defer { try? FileManager.default.removeItem(at: url) }

        try seedLegacyStore(at: url)

        let context = ModelContext(try AppModelContainer.make(url: url))
        let category = try #require(try context.fetch(FetchDescriptor<ExpenseTracker.Category>()).first)

        #expect(category.transactions.count == 1)
        #expect(category.budgetPlans.count == 1)

        context.delete(category)
        try context.saveOrRollback()

        let transactions = try context.fetch(FetchDescriptor<Transaction>())
        #expect(transactions.count == 1)
        #expect(transactions.first?.category == nil)
        #expect(try context.fetchCount(FetchDescriptor<BudgetPlan>()) == 0)
    }

    @Test func savedChangesSurviveReopening() throws {
        let url = makeStoreURL()
        defer { try? FileManager.default.removeItem(at: url) }

        do {
            let context = ModelContext(try AppModelContainer.make(url: url))
            context.insert(Transaction(amount: 100, date: .now, type: .expense))
            try context.saveOrRollback()
        }

        let reopened = ModelContext(try AppModelContainer.make(url: url))
        #expect(try reopened.fetchCount(FetchDescriptor<Transaction>()) == 1)
    }
}

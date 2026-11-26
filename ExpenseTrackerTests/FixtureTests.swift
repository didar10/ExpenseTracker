//
//  FixtureTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 25.11.2026.
//

import Foundation
import SwiftData
import Testing
@testable import ExpenseTracker

@MainActor
struct FixtureTests {

    // MARK: - Sample

    @Test func sampleHasAccounts() throws {
        let environment = FixtureEnvironment(.sample)

        let names = try environment.context.fetch(FetchDescriptor<Account>()).map(\.name)

        #expect(Set(names) == ["Freedom", "Kaspi Gold", "Наличные"])
    }

    @Test func sampleHasLimitAndBudgets() throws {
        let environment = FixtureEnvironment(.sample)

        let budgets = try environment.context.fetch(FetchDescriptor<BudgetPlan>())

        #expect(environment.limitStore.limit != nil)
        #expect(!budgets.isEmpty)
        #expect(budgets.allSatisfy { $0.category != nil })
    }

    /// В начале, середине и конце месяца все операции — в этом месяце и не в будущем
    @Test(arguments: [1, 15, 28])
    func sampleTransactionsStayInCurrentMonth(day: Int) throws {
        let now = try #require(date(day: day))
        let environment = FixtureEnvironment(.sample, now: now)
        let month = try #require(Calendar.current.dateInterval(of: .month, for: now))

        let transactions = try environment.context.fetch(FetchDescriptor<Transaction>())

        #expect(!transactions.isEmpty)
        #expect(transactions.allSatisfy { $0.date >= month.start && $0.date <= now })
        #expect(transactions.contains { $0.type == .income })
        #expect(transactions.contains { $0.type == .expense })
        let transfers = transactions.filter { $0.kind == .transfer }
        #expect(transfers.count == 3)
        #expect(transfers.allSatisfy { $0.amount > 0 && $0.category == nil && $0.fromAccount != nil && $0.toAccount != nil && $0.fromAccount !== $0.toAccount })
    }

    // MARK: - Empty

    @Test func emptyHasNoData() throws {
        let environment = FixtureEnvironment(.empty)
        let context = environment.context

        #expect(try context.fetchCount(FetchDescriptor<Account>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<ExpenseTracker.Category>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<Transaction>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<BudgetPlan>()) == 0)
        #expect(environment.limitStore.limit == nil)
    }

    // MARK: - Replace

    /// Отладочная загрузка не смешивает фикстуру со старыми данными и значениями по умолчанию
    @Test func replaceAllDataLeavesOnlyFixture() throws {
        let environment = FixtureEnvironment(.empty)
        let repository = environment.repositories.appData
        repository.seedDefaultsIfNeeded()

        try repository.replaceAllData(with: .sample)

        let names = try environment.context.fetch(FetchDescriptor<Account>()).map(\.name)
        #expect(Set(names) == ["Freedom", "Kaspi Gold", "Наличные"])
        #expect(names.count == 3)
    }

    // MARK: - Helpers

    private func date(day: Int) -> Date? {
        var components = Calendar.current.dateComponents([.year, .month], from: .now)
        components.day = day
        components.hour = 9

        return Calendar.current.date(from: components)
    }
}

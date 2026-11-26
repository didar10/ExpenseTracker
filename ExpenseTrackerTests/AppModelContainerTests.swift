import Foundation
import SwiftData
import Testing
@testable import ExpenseTracker

@MainActor
struct AppModelContainerTests {
    @Test func deletingCategoryKeepsOperationsAndRemovesBudgets() throws {
        let context = ModelContext(try AppModelContainer.make(inMemory: true))
        let category = ExpenseTracker.Category(name: "Еда", icon: "basket", colorHex: "#8EE3A1")
        context.insert(category)
        context.insert(Transaction(amount: 250, date: .now, type: .expense, category: category))
        context.insert(BudgetPlan(category: category, monthlyLimit: 50_000))
        try context.save()

        context.delete(category)
        try context.save()

        let transactions = try context.fetch(FetchDescriptor<Transaction>())
        #expect(transactions.count == 1)
        #expect(transactions.first?.category == nil)
        #expect(try context.fetchCount(FetchDescriptor<BudgetPlan>()) == 0)
    }

    @Test func transferAndBothAccountLinksSurviveReopening() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("transfer.store")

        do {
            let context = ModelContext(try AppModelContainer.make(url: url))
            let from = Account(name: "Карта", initialBalance: 1_000)
            let to = Account(name: "Наличные", initialBalance: 100)
            context.insert(from)
            context.insert(to)
            try context.save()
            try SwiftDataTransactionRepository(context: context).add(
                TransactionDraft(amount: 250, date: .now, fromAccount: from, toAccount: to)
            )
        }

        let reopened = ModelContext(try AppModelContainer.make(url: url))
        let transfer = try #require(try reopened.fetch(FetchDescriptor<Transaction>()).first)
        #expect(transfer.kind == .transfer)
        #expect(transfer.amount == 250)
        #expect(transfer.category == nil)
        #expect(transfer.account == nil)
        #expect(transfer.fromAccount?.name == "Карта")
        #expect(transfer.toAccount?.name == "Наличные")
        #expect(transfer.fromAccount?.currentBalance == 750)
        #expect(transfer.toAccount?.currentBalance == 350)
    }
}

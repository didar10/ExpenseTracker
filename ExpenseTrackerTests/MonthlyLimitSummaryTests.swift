//
//  MonthlyLimitSummaryTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 26.10.2026.
//

import Foundation
import SwiftData
import Testing
@testable import ExpenseTracker

@MainActor
struct MonthlyLimitSummaryTests {

    // MARK: - Helpers

    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Almaty") ?? .current
        return calendar
    }()

    /// Октябрь 2026: 31 день
    private func october(_ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour)) ?? .now
    }

    private func expense(_ amount: Decimal, on date: Date) -> Transaction {
        Transaction(amount: amount, date: date, type: .expense)
    }

    private func budget(_ limit: Decimal, in context: ModelContext) -> BudgetPlan {
        let category = Category(name: "Еда", icon: "cart", colorHex: "#FF0000")
        context.insert(category)
        let plan = BudgetPlan(category: category, monthlyLimit: limit)
        context.insert(plan)
        return plan
    }

    // MARK: - Tests

    @Test func remainingIsSplitPerDayIncludingToday() {
        let summary = MonthlyLimitSummary(
            limit: 300_000,
            transactions: [expense(200_000, on: october(10)), expense(4_000, on: october(26)), expense(9_000, on: october(30))],
            monthlyBudgets: [],
            now: october(26),
            calendar: calendar
        )

        // Операция с будущей датой не считается; с 26 по 31 — 6 дней
        #expect(summary.spent == 204_000)
        #expect(summary.remaining == 96_000)
        #expect(summary.perDay == 16_000)
    }

    @Test func exceededLimitGivesNegativeRemainingAndZeroPerDay() {
        let summary = MonthlyLimitSummary(
            limit: 100_000,
            transactions: [expense(120_000, on: october(5))],
            monthlyBudgets: [],
            now: october(26),
            calendar: calendar
        )

        #expect(summary.remaining == -20_000)
        #expect(summary.perDay == 0)
        #expect(summary.pace.level == .over)
    }

    @Test func categoryBudgetsAboveLimitAreOverAllocated() throws {
        let context = ModelContext(try AppModelContainer.make(inMemory: true))
        let budgets = [budget(80_000, in: context), budget(50_000, in: context)]

        let summary = MonthlyLimitSummary(
            limit: 100_000,
            transactions: [],
            monthlyBudgets: budgets,
            now: october(26),
            calendar: calendar
        )

        #expect(summary.allocated == 130_000)
        #expect(summary.isOverAllocated)
        #expect(summary.overAllocation == 30_000)
    }

    @Test func viewModelSummaryCountsOnlyMonthlyBudgetsAndNeedsLimit() throws {
        let context = ModelContext(try AppModelContainer.make(inMemory: true))
        let store = MonthlyLimitStore(defaults: UserDefaults(suiteName: UUID().uuidString) ?? .standard)
        let viewModel = PlansViewModel(limitStore: store)
        let monthly = budget(40_000, in: context)
        let weekly = budget(10_000, in: context)
        weekly.period = .week
        viewModel.updateData(budgetPlans: [monthly, weekly], transactions: [])

        #expect(viewModel.monthlyLimitSummary == nil)

        store.setLimit(100_000)

        #expect(viewModel.monthlyLimitSummary?.allocated == 40_000)
    }
}

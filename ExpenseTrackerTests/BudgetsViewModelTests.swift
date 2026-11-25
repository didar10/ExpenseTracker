//
//  BudgetsViewModelTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 25.11.2026.
//

import Foundation
import SwiftData
import Testing
@testable import ExpenseTracker

/// Расчеты экрана «Бюджеты»: остаток и сумма на день, темп, полоса трат,
/// бюджеты категорий и нераспределенная часть лимита
@MainActor
struct BudgetsViewModelTests {

    // MARK: - Helpers

    private struct SaveFailure: Error {}

    private struct FailingBudgetRepository: BudgetPlanRepository {
        func add(_ draft: BudgetPlanDraft) throws -> BudgetPlan { throw SaveFailure() }
        func delete(_ plan: BudgetPlan) throws { throw SaveFailure() }
    }

    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Almaty") ?? .current
        return calendar
    }()

    private let context: ModelContext
    private let store = MonthlyLimitStore(defaults: UserDefaults(suiteName: UUID().uuidString) ?? .standard)

    init() throws {
        context = ModelContext(try AppModelContainer.make(inMemory: true))
    }

    /// Ноябрь 2026: 30 дней. «Сегодня» — 20-е, как в макете: до конца месяца 11 дней
    private func november(_ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour)) ?? .now
    }

    private func october(_ day: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: 12)) ?? .now
    }

    private func makeViewModel(now: Date? = nil) -> BudgetsViewModel {
        let date = now ?? november(20)
        return BudgetsViewModel(limitStore: store, now: { date }, calendar: calendar)
    }

    private func category(_ name: String, hex: String = "#34C759") -> ExpenseTracker.Category {
        let category = Category(name: name, icon: "cart", colorHex: hex)
        context.insert(category)
        return category
    }

    private func budget(_ limit: Decimal, for category: ExpenseTracker.Category, period: BudgetPeriod = .month) -> BudgetPlan {
        let plan = BudgetPlan(category: category, monthlyLimit: limit, period: period)
        context.insert(plan)
        return plan
    }

    private func expense(_ amount: Decimal, on date: Date, category: ExpenseTracker.Category? = nil) -> Transaction {
        Transaction(amount: amount, date: date, type: .expense, category: category)
    }

    // MARK: - Limit Card

    @Test func remainingAndPerDayFollowMockup() {
        store.setLimit(250_000)
        let viewModel = makeViewModel()
        viewModel.updateData(budgetPlans: [], transactions: [expense(100_000, on: november(3)), expense(31_950, on: november(20, hour: 9))])

        let overview = viewModel.limitOverview

        #expect(overview?.spent == 131_950)
        #expect(overview?.remaining == 118_050)
        #expect(overview?.daysLeft == 11)
        // 118 050 / 11 = 10 731,8 — вниз, чтобы не выйти за лимит
        #expect(overview?.perDay == 10_731)
    }

    @Test func futureIncomeAndOtherMonthsAreNotSpent() {
        store.setLimit(100_000)
        let viewModel = makeViewModel()
        viewModel.updateData(budgetPlans: [], transactions: [
            expense(10_000, on: november(5)),
            expense(7_000, on: november(25)),
            expense(3_000, on: october(31)),
            Transaction(amount: 500_000, date: november(1), type: .income)
        ])

        #expect(viewModel.limitOverview?.spent == 10_000)
    }

    @Test func exceededLimitHasNegativeRemainingAndZeroPerDay() {
        store.setLimit(100_000)
        let viewModel = makeViewModel()
        viewModel.updateData(budgetPlans: [], transactions: [expense(120_000, on: november(5))])

        #expect(viewModel.limitOverview?.isExceeded == true)
        #expect(viewModel.limitOverview?.remaining == -20_000)
        #expect(viewModel.limitOverview?.perDay == 0)
    }

    @Test func pastMonthHasNoPerDayAndPace() {
        store.setLimit(100_000)
        let viewModel = makeViewModel()
        viewModel.updateData(budgetPlans: [], transactions: [expense(40_000, on: october(10)), expense(5_000, on: november(2))])

        viewModel.goToPreviousMonth()

        #expect(viewModel.limitOverview?.spent == 40_000)
        #expect(viewModel.limitOverview?.daysLeft == nil)
        #expect(viewModel.limitOverview?.perDay == nil)
        #expect(viewModel.limitOverview?.pace == nil)
    }

    @Test func noLimitMeansNoOverview() {
        let viewModel = makeViewModel()
        viewModel.updateData(budgetPlans: [], transactions: [expense(1_000, on: november(5))])

        #expect(viewModel.limitOverview == nil)
        #expect(viewModel.unallocated == nil)
    }

    // MARK: - Pace

    @Test func slowerThanPlanIsInNorm() {
        // К концу 20-го из 30 дней план — 2/3 лимита: 200 000 из 300 000.
        // Потрачено 184 000 — на 8% медленнее
        store.setLimit(300_000)
        let viewModel = makeViewModel()
        viewModel.updateData(budgetPlans: [], transactions: [expense(184_000, on: november(10))])

        #expect(viewModel.limitOverview?.pace == LimitPace(percent: 8, isFaster: false))
    }

    @Test func fasterThanPlanIsFlagged() {
        store.setLimit(300_000)
        let viewModel = makeViewModel()
        viewModel.updateData(budgetPlans: [], transactions: [expense(230_000, on: november(10))])

        #expect(viewModel.limitOverview?.pace == LimitPace(percent: 15, isFaster: true))
    }

    @Test func firstDayOfMonthAlreadyHasPlan() {
        // 1-е число — прошла 1/30 месяца: план 10 000 из 300 000
        store.setLimit(300_000)
        let viewModel = makeViewModel(now: november(1))
        viewModel.updateData(budgetPlans: [], transactions: [expense(10_000, on: november(1, hour: 9))])

        #expect(viewModel.limitOverview?.pace == LimitPace(percent: 0, isFaster: false))
        #expect(viewModel.limitOverview?.daysLeft == 30)
    }

    @Test func paceNeedsLimitAndElapsedTime() {
        #expect(LimitPace(spent: 100, limit: 0, elapsedFraction: 0.5) == nil)
        #expect(LimitPace(spent: 100, limit: 1_000, elapsedFraction: 0) == nil)
    }

    // MARK: - Spending Bar

    @Test func segmentsAreCategoriesBySpendingShareOfLimit() {
        store.setLimit(200_000)
        let food = category("Еда", hex: "#34C759")
        let home = category("Дом", hex: "#AF52DE")
        let viewModel = makeViewModel()
        viewModel.updateData(budgetPlans: [], transactions: [
            expense(20_000, on: november(2), category: food),
            expense(50_000, on: november(3), category: home),
            expense(10_000, on: november(4))
        ])

        let segments = viewModel.limitOverview?.segments ?? []

        #expect(segments.map(\.fraction) == [0.25, 0.1, 0.05])
        #expect(segments.map(\.color) == [.purple, .green, nil])
    }

    @Test func overspentSegmentsFillWholeBar() {
        store.setLimit(100_000)
        let food = category("Еда")
        let viewModel = makeViewModel()
        viewModel.updateData(budgetPlans: [], transactions: [
            expense(90_000, on: november(2), category: food),
            expense(110_000, on: november(3))
        ])

        let total = viewModel.limitOverview?.segments.reduce(0) { $0 + $1.fraction }

        #expect(total == 1)
    }

    // MARK: - Category Budgets

    @Test func statusThresholds() {
        store.setLimit(500_000)
        let names = ["79", "80", "99,9", "100", "114"]
        let spent: [Decimal] = [79_000, 80_000, 99_900, 100_000, 114_000]
        let categories = names.map { category($0) }
        let plans = categories.map { budget(100_000, for: $0) }
        let transactions = zip(categories, spent).map { expense($1, on: november(5), category: $0) }
        let viewModel = makeViewModel()
        viewModel.updateData(budgetPlans: plans, transactions: transactions)

        let statuses = Dictionary(uniqueKeysWithValues: viewModel.items.map { ($0.name, ($0.status, $0.percent)) })

        #expect(statuses["79"]?.0 == .normal)
        #expect(statuses["80"]?.0 == .warning)
        #expect(statuses["99,9"]?.0 == .warning)
        #expect(statuses["99,9"]?.1 == 99)
        #expect(statuses["100"]?.0 == .exceeded)
        #expect(statuses["114"]?.0 == .exceeded)
    }

    @Test func exceededBudgetsComeFirst() {
        let shopping = category("Покупки")
        let home = category("Дом")
        let food = category("Еда")
        let plans = [budget(60_000, for: food), budget(80_000, for: home), budget(25_000, for: shopping)]
        let viewModel = makeViewModel()
        viewModel.updateData(budgetPlans: plans, transactions: [
            expense(20_650, on: november(2), category: food),
            expense(65_000, on: november(3), category: home),
            expense(28_500, on: november(4), category: shopping)
        ])

        #expect(viewModel.items.map(\.name) == ["Покупки", "Дом", "Еда"])
        #expect(viewModel.items.first?.overspent == 3_500)
    }

    @Test func categoryPerDaySplitsRemainingOverDaysLeft() {
        let home = category("Дом")
        let viewModel = makeViewModel()
        viewModel.updateData(budgetPlans: [budget(80_000, for: home)], transactions: [expense(65_000, on: november(3), category: home)])

        let item = viewModel.items.first

        #expect(item?.remaining == 15_000)
        // 15 000 / 11 = 1 363,6 — вниз
        #expect(item?.perDay == 1_363)
        #expect(item?.paceMarker == 20.0 / 30.0)
    }

    @Test func exceededOrPastBudgetHasNoPerDay() {
        let home = category("Дом")
        let food = category("Еда")
        let viewModel = makeViewModel()
        viewModel.updateData(
            budgetPlans: [budget(10_000, for: home), budget(50_000, for: food)],
            transactions: [expense(12_000, on: november(3), category: home)]
        )

        #expect(viewModel.items.first { $0.name == "Дом" }?.perDay == nil)

        viewModel.goToPreviousMonth()

        #expect(viewModel.items.allSatisfy { $0.perDay == nil && $0.paceMarker == nil })
    }

    // MARK: - Allocation

    @Test func unallocatedIsLimitMinusMonthlyBudgets() {
        store.setLimit(250_000)
        let plans = [
            budget(25_000, for: category("Покупки")),
            budget(80_000, for: category("Дом")),
            budget(20_000, for: category("Транспорт")),
            budget(60_000, for: category("Еда")),
            budget(5_000, for: category("Кофе"), period: .week)
        ]
        let viewModel = makeViewModel()
        viewModel.updateData(budgetPlans: plans, transactions: [])

        #expect(viewModel.allocated == 185_000)
        #expect(viewModel.unallocated == 65_000)
        #expect(viewModel.items.count == 4)
    }

    @Test func overAllocationIsNegative() {
        store.setLimit(100_000)
        let viewModel = makeViewModel()
        viewModel.updateData(budgetPlans: [budget(80_000, for: category("Дом")), budget(50_000, for: category("Еда"))], transactions: [])

        #expect(viewModel.unallocated == -30_000)
    }

    // MARK: - Empty State

    @Test func emptyOnlyWithoutLimitAndBudgets() {
        let viewModel = makeViewModel()
        viewModel.updateData(budgetPlans: [], transactions: [])

        #expect(viewModel.isEmpty)

        store.setLimit(100_000)

        #expect(!viewModel.isEmpty)

        store.setLimit(nil)
        viewModel.updateData(budgetPlans: [budget(10_000, for: category("Еда"))], transactions: [])

        #expect(!viewModel.isEmpty)
    }

    // MARK: - Month Navigation

    @Test func cannotGoPastCurrentMonth() {
        let viewModel = makeViewModel()

        #expect(!viewModel.canGoToNextMonth)

        viewModel.goToNextMonth()
        viewModel.selectMonth(offset: 2)

        #expect(viewModel.monthOffset == 0)

        viewModel.goToPreviousMonth()

        #expect(viewModel.canGoToNextMonth)

        viewModel.goToNextMonth()

        #expect(viewModel.monthOffset == 0)
    }

    @Test func monthTitleHasYear() {
        let month = BudgetMonth(offset: 0, now: november(20), calendar: calendar)

        #expect(month.title(locale: Locale(identifier: "ru_RU")) == "Ноябрь 2026")
        #expect(makeViewModel().monthOptions.first?.offset == 0)
        #expect(makeViewModel().monthOptions.count == 6)
    }

    // MARK: - Delete

    @Test func deleteRemovesBudget() {
        let plan = budget(10_000, for: category("Еда"))
        let viewModel = makeViewModel()
        viewModel.updateData(budgetPlans: [plan], transactions: [])

        viewModel.requestDelete(viewModel.items[0])

        #expect(viewModel.showingDeleteConfirmation)

        viewModel.confirmDelete(using: SwiftDataBudgetPlanRepository(context: context))

        #expect(viewModel.items.isEmpty)
        #expect(!viewModel.showingSaveError)
    }

    @Test func failedDeleteShowsErrorAndKeepsBudget() {
        let plan = budget(10_000, for: category("Еда"))
        let viewModel = makeViewModel()
        viewModel.updateData(budgetPlans: [plan], transactions: [])

        viewModel.requestDelete(viewModel.items[0])
        viewModel.confirmDelete(using: FailingBudgetRepository())

        #expect(viewModel.showingSaveError)
        #expect(viewModel.items.count == 1)
    }
}

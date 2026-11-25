//
//  AddBudgetViewModelTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 26.11.2026.
//

import Foundation
import SwiftData
import Testing
@testable import ExpenseTracker

/// «Новый бюджет»: какие категории в ленте, пресеты по прошлым тратам,
/// подсказка о нераспределенном лимите, кнопка и сохранение
@MainActor
struct AddBudgetViewModelTests {

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

    init() throws {
        context = ModelContext(try AppModelContainer.make(inMemory: true))
    }

    /// «Сегодня» — 20 ноября 2026: прошлый месяц — октябрь
    private var now: Date {
        date(month: 11, day: 20)
    }

    private func date(month: Int, day: Int = 10) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: 12)) ?? .now
    }

    private func category(_ name: String, type: TransactionType = .expense) -> ExpenseTracker.Category {
        let category = Category(name: name, icon: "cart", colorHex: "#34C759", type: type)
        context.insert(category)
        return category
    }

    private func budget(_ limit: Decimal, for category: ExpenseTracker.Category, period: BudgetPeriod = .month, isActive: Bool = true) -> BudgetPlan {
        let plan = BudgetPlan(category: category, monthlyLimit: limit, period: period, isActive: isActive)
        context.insert(plan)
        return plan
    }

    private func expense(_ amount: Decimal, month: Int, category: ExpenseTracker.Category) -> Transaction {
        Transaction(amount: amount, date: date(month: month), type: .expense, category: category)
    }

    private func makeViewModel(
        categories: [ExpenseTracker.Category],
        budgets: [BudgetPlan] = [],
        transactions: [Transaction] = [],
        limit: Decimal? = 250_000
    ) -> AddBudgetViewModel {
        AddBudgetViewModel(
            categories: categories,
            budgetPlans: budgets,
            transactions: transactions,
            limit: limit,
            now: now,
            calendar: calendar
        )
    }

    /// Еда: октябрь 18 400, сентябрь 21 000, август 20 300, плюс ноябрь и июль — не считаются
    private func foodWithHistory() -> (ExpenseTracker.Category, [Transaction]) {
        let food = category("Еда")
        let transactions = [
            expense(10_000, month: 10, category: food),
            expense(8_400, month: 10, category: food),
            expense(21_000, month: 9, category: food),
            expense(20_300, month: 8, category: food),
            expense(50_000, month: 11, category: food),
            expense(99_000, month: 7, category: food)
        ]
        return (food, transactions)
    }

    // MARK: - Categories

    @Test func onlyExpenseCategoriesWithoutActiveBudget() {
        let food = category("Еда")
        let home = category("Дом")
        let coffee = category("Кофе")
        let salary = category("Зарплата", type: .income)
        let viewModel = makeViewModel(
            categories: [food, home, coffee, salary],
            budgets: [budget(50_000, for: home), budget(5_000, for: coffee, isActive: false)]
        )

        #expect(Set(viewModel.categories.map(\.name)) == ["Еда", "Кофе"])
    }

    @Test func carouselIsOrderedByLastMonthWithCaption() {
        let (food, transactions) = foodWithHistory()
        let home = category("Дом")
        let viewModel = makeViewModel(categories: [home, food], transactions: transactions + [expense(5_000, month: 10, category: home)])

        #expect(viewModel.carouselItems.map(\.title) == ["Еда", "Дом"])
        #expect(viewModel.carouselItems.first?.spendCaption == AppString.addBudgetSpentInMonth(MoneyFormat.money(18_400), month: 10))
    }

    // MARK: - Presets

    @Test func presetsFollowPastSpending() {
        let (food, transactions) = foodWithHistory()
        let viewModel = makeViewModel(categories: [food], transactions: transactions)
        viewModel.selectedCategoryID = food.id

        // 18 400 × 0,9 = 16 560 → 16 600; (18 400 + 21 000 + 20 300) / 3 = 19 900
        #expect(viewModel.presets.map(\.amount) == [18_400, 16_600, 19_900])
    }

    @Test func averageCountsMissingMonthsAsZero() {
        let food = category("Еда")
        let viewModel = makeViewModel(categories: [food], transactions: [expense(30_000, month: 10, category: food)])
        viewModel.selectedCategoryID = food.id

        #expect(viewModel.presets.last?.amount == 10_000)
    }

    @Test func noCategoryMeansNoPresetAmounts() {
        let (food, transactions) = foodWithHistory()
        let viewModel = makeViewModel(categories: [food], transactions: transactions)

        #expect(viewModel.presets.allSatisfy { $0.amount == nil })
    }

    @Test func selectingPresetSetsAmountAndHighlightsIt() {
        let (food, transactions) = foodWithHistory()
        let viewModel = makeViewModel(categories: [food], transactions: transactions)
        viewModel.selectedCategoryID = food.id

        viewModel.selectPreset(16_600)

        #expect(viewModel.amount == 16_600)
        #expect(viewModel.presets.map(viewModel.isSelected) == [false, true, false])
    }

    // MARK: - Limit Hint

    @Test func hintShowsWhatStaysUnallocated() {
        let food = category("Еда")
        let budgets = [
            budget(25_000, for: category("Покупки")),
            budget(80_000, for: category("Дом")),
            budget(20_000, for: category("Транспорт")),
            budget(60_000, for: category("Кафе")),
            budget(7_000, for: category("Кофе"), period: .week),
            budget(9_000, for: category("Кино"), isActive: false)
        ]
        let viewModel = makeViewModel(categories: [food], budgets: budgets)
        viewModel.selectedCategoryID = food.id
        viewModel.selectPreset(45_000)

        #expect(viewModel.unallocatedAfterSave == 20_000)
        #expect(viewModel.limitHint?.text == AppString.addBudgetUnallocatedHint(MoneyFormat.money(250_000), MoneyFormat.money(20_000)))
        #expect(viewModel.limitHint?.highlighted == MoneyFormat.money(20_000))
    }

    @Test func hintWarnsWhenBudgetsExceedLimit() {
        let food = category("Еда")
        let viewModel = makeViewModel(categories: [food], budgets: [budget(240_000, for: category("Дом"))])
        viewModel.selectPreset(15_000)

        #expect(viewModel.unallocatedAfterSave == -5_000)
        #expect(viewModel.limitHint?.text == AppString.addBudgetOverLimitHint(MoneyFormat.money(250_000), MoneyFormat.money(5_000)))
    }

    @Test func noHintWithoutLimitOrAmount() {
        let food = category("Еда")

        #expect(makeViewModel(categories: [food]).limitHint == nil)

        let withoutLimit = makeViewModel(categories: [food], limit: nil)
        withoutLimit.selectPreset(10_000)

        #expect(withoutLimit.limitHint == nil)
    }

    // MARK: - Save Button

    @Test func buttonTitleFollowsState() {
        let food = category("Еда")
        let viewModel = makeViewModel(categories: [food])

        #expect(viewModel.saveButtonTitle == AppString.selectCategory)
        #expect(!viewModel.canSave)

        viewModel.selectedCategoryID = food.id

        #expect(viewModel.saveButtonTitle == AppString.enterAmount)
        #expect(!viewModel.canSave)

        viewModel.press(.digit(5))
        viewModel.press(.tripleZero)

        #expect(viewModel.saveButtonTitle == AppString.createBudget)
        #expect(viewModel.canSave)
    }

    @Test func periodIsMonthOnly() {
        let viewModel = makeViewModel(categories: [])

        #expect(viewModel.period == .month)
        #expect(viewModel.availablePeriods == [.month])
    }

    // MARK: - Save

    @Test func saveStoresBudgetWithOptions() throws {
        let food = category("Еда")
        let viewModel = makeViewModel(categories: [food])
        viewModel.selectedCategoryID = food.id
        viewModel.selectPreset(45_000)
        viewModel.carriesOverRemainder = false

        #expect(viewModel.save(using: SwiftDataBudgetPlanRepository(context: context)))

        let plan = try #require(try context.fetch(FetchDescriptor<BudgetPlan>()).first)
        #expect(plan.category?.id == food.id)
        #expect(plan.monthlyLimit == 45_000)
        #expect(plan.period == .month)
        #expect(!plan.carriesOverRemainder)
        #expect(plan.warnsNearLimit)
    }

    @Test func failedSaveShowsErrorAndKeepsSheet() {
        let food = category("Еда")
        let viewModel = makeViewModel(categories: [food])
        viewModel.selectedCategoryID = food.id
        viewModel.selectPreset(45_000)

        #expect(!viewModel.save(using: FailingBudgetRepository()))
        #expect(viewModel.showingSaveError)
    }

    @Test func cannotSaveWithoutCategory() {
        let viewModel = makeViewModel(categories: [category("Еда")])
        viewModel.selectPreset(45_000)

        #expect(!viewModel.save(using: FailingBudgetRepository()))
        #expect(!viewModel.showingSaveError)
    }
}

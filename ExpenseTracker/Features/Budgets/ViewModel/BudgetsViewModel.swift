//
//  BudgetsViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftData
import SwiftUI

/// Экран «Бюджеты»: общий лимит на месяц и месячные бюджеты категорий за выбранный месяц
@MainActor
@Observable
final class BudgetsViewModel {

    // MARK: - Types

    /// Пункт меню выбора месяца
    struct MonthOption: Identifiable, Equatable {
        let offset: Int
        let title: String

        var id: Int { offset }
    }

    // MARK: - Properties

    var showingAddBudget = false
    var showingMonthlyLimit = false
    var showingDeleteConfirmation = false
    var showingSaveError = false

    /// 0 — текущий месяц, −1 — прошлый
    private(set) var monthOffset = 0
    /// Бюджеты категорий: сначала самые потраченные, превышенные — сверху
    private(set) var items: [CategoryBudgetItem] = []
    /// Траты месяца по категориям, по убыванию; ключ nil — без категории
    private(set) var spending: [(category: Category?, amount: Decimal)] = []
    private(set) var monthSpent: Decimal = 0
    /// Сумма месячных бюджетов категорий
    private(set) var allocated: Decimal = 0

    let limitStore: MonthlyLimitStore

    private var monthlyPlans: [BudgetPlan] = []
    private var transactions: [Transaction] = []
    private var planToDelete: BudgetPlan?

    /// Текущий момент и календарь; подменяются в тестах
    private let now: () -> Date
    private let calendar: Calendar

    // MARK: - Init

    init(limitStore: MonthlyLimitStore, now: @escaping () -> Date = { .now }, calendar: Calendar = .current) {
        self.limitStore = limitStore
        self.now = now
        self.calendar = calendar
    }

    // MARK: - Computed Properties

    var month: BudgetMonth {
        BudgetMonth(offset: monthOffset, now: now(), calendar: calendar)
    }

    var monthTitle: String {
        month.title()
    }

    var canGoToNextMonth: Bool {
        monthOffset < 0
    }

    /// Ни лимита, ни бюджетов — экран объясняет, как начать
    var isEmpty: Bool {
        limitStore.limit == nil && monthlyPlans.isEmpty
    }

    /// nil — лимит на месяц не задан
    var limitOverview: MonthlyLimitOverview? {
        guard let limit = limitStore.limit else { return nil }

        let month = month
        let spent = monthSpent
        // Перерасход заполняет полосу целиком: шкала — большее из лимита и трат
        let scale = max(limit, spent)

        let segments = spending.compactMap { entry -> SpendingSegment? in
            guard scale > 0, entry.amount > 0 else { return nil }

            return SpendingSegment(
                id: entry.category?.id.uuidString ?? Constants.noCategorySegmentID,
                color: entry.category.map { DS.CategoryColor(legacyHex: $0.colorHex) },
                fraction: NSDecimalNumber(decimal: entry.amount / scale).doubleValue
            )
        }

        return MonthlyLimitOverview(
            limit: limit,
            spent: spent,
            segments: segments,
            daysLeft: month.daysLeft,
            perDay: month.daysLeft.map { Self.perDay(limit - spent, days: $0) },
            pace: month.elapsedFraction.flatMap { LimitPace(spent: spent, limit: limit, elapsedFraction: $0) }
        )
    }

    /// Лимит минус бюджеты категорий; отрицательный — распределено больше лимита.
    /// nil — лимит не задан
    var unallocated: Decimal? {
        limitStore.limit.map { $0 - allocated }
    }

    /// Последние месяцы для меню под названием периода, текущий — первым
    var monthOptions: [MonthOption] {
        (0..<Constants.menuMonthCount).map { index in
            let offset = -index
            return MonthOption(offset: offset, title: BudgetMonth(offset: offset, now: now(), calendar: calendar).title())
        }
    }

    // MARK: - Data

    func updateData(budgetPlans: [BudgetPlan], transactions: [Transaction]) {
        // Экран месячный: недельные и годовые бюджеты сюда не попадают
        monthlyPlans = budgetPlans.filter { $0.isActive && $0.period == .month && $0.category != nil }
        self.transactions = transactions
        recalculate()
    }

    // MARK: - Month Navigation

    func goToPreviousMonth() {
        selectMonth(offset: monthOffset - 1)
    }

    func goToNextMonth() {
        guard canGoToNextMonth else { return }
        selectMonth(offset: monthOffset + 1)
    }

    /// В будущее листать нельзя: смещение не больше нуля
    func selectMonth(offset: Int) {
        let clamped = min(offset, 0)
        guard clamped != monthOffset else { return }

        monthOffset = clamped
        recalculate()
    }

    // MARK: - Actions

    func addBudget() {
        showingAddBudget = true
    }

    func editMonthlyLimit() {
        showingMonthlyLimit = true
    }

    func requestDelete(_ item: CategoryBudgetItem) {
        planToDelete = monthlyPlans.first { $0.persistentModelID == item.id }
        showingDeleteConfirmation = planToDelete != nil
    }

    func cancelDelete() {
        planToDelete = nil
    }

    func confirmDelete(using repository: BudgetPlanRepository) {
        guard let plan = planToDelete else { return }
        planToDelete = nil

        do {
            try repository.delete(plan)
            monthlyPlans.removeAll { $0.persistentModelID == plan.persistentModelID }
            recalculate()
        } catch {
            showingSaveError = true
        }
    }

    // MARK: - Private Methods

    /// Пересчет при смене данных или месяца: перебирает все операции один раз
    private func recalculate() {
        let month = month
        let currentDate = now()

        // Операции с датой в будущем еще не потрачены
        var byCategory: [PersistentIdentifier?: (category: Category?, amount: Decimal)] = [:]
        for transaction in transactions
        where transaction.type == .expense && month.interval.contains(transaction.date) && transaction.date <= currentDate {
            let key = transaction.category?.persistentModelID
            byCategory[key, default: (transaction.category, 0)].amount += transaction.amount
        }

        spending = byCategory.values.sorted { $0.amount > $1.amount }
        monthSpent = spending.reduce(0) { $0 + $1.amount }
        allocated = monthlyPlans.reduce(0) { $0 + $1.monthlyLimit }

        items = monthlyPlans
            .compactMap { plan -> CategoryBudgetItem? in
                guard let category = plan.category else { return nil }

                let spent = byCategory[category.persistentModelID]?.amount ?? 0
                let remaining = plan.monthlyLimit - spent

                return CategoryBudgetItem(
                    id: plan.persistentModelID,
                    name: category.name,
                    iconName: category.icon,
                    color: DS.CategoryColor(legacyHex: category.colorHex),
                    spent: spent,
                    limit: plan.monthlyLimit,
                    perDay: remaining > 0 ? month.daysLeft.map { Self.perDay(remaining, days: $0) } : nil,
                    paceMarker: month.elapsedFraction
                )
            }
            .sorted { lhs, rhs in
                lhs.progress == rhs.progress
                    ? lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
                    : lhs.progress > rhs.progress
            }
    }

    /// Остаток поровну на дни, без копеек и вниз: так за месяц не выйти за лимит
    nonisolated static func perDay(_ remaining: Decimal, days: Int) -> Decimal {
        guard remaining > 0, days > 0 else { return 0 }

        var source = remaining / Decimal(days)
        var result = Decimal()
        NSDecimalRound(&result, &source, 0, .down)
        return result
    }
}

// MARK: - Constants

private extension BudgetsViewModel {

    enum Constants {
        /// Полгода в меню выбора месяца
        static let menuMonthCount = 6
        static let noCategorySegmentID = "noCategory"
    }
}

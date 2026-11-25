//
//  AddBudgetViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 26.11.2026.
//

import SwiftUI

/// «Новый бюджет»: категория из ленты (только те, у которых бюджета еще нет), сумма
/// с клавиатуры или пресета по прошлым тратам, переключатели и подсказка, сколько лимита
/// останется нераспределено
@MainActor
@Observable
final class AddBudgetViewModel {

    // MARK: - Types

    enum PresetKind: String {
        /// Траты прошлого месяца
        case lastMonth
        /// Прошлый месяц минус 10%
        case minusTenPercent
        /// Среднее за три прошлых месяца
        case threeMonthAverage
    }

    // MARK: - Properties

    /// nil — «Без категории», создать бюджет нельзя
    var selectedCategoryID: UUID?
    var carriesOverRemainder = true
    var warnsNearLimit = true
    var showingSaveError = false

    private(set) var input = DigitAmountInput()

    /// Пока экран «Бюджеты» показывает только месячные бюджеты, неделя и год недоступны
    let period: BudgetPeriod = .month
    let availablePeriods: Set<BudgetPeriod> = [.month]

    /// Категории расходов без активного бюджета
    let categories: [Category]

    /// Траты по категориям за прошлые месяцы: [0] — прошлый, [1] — позапрошлый, [2] — три месяца назад
    private let history: [UUID: [Decimal]]
    private let limit: Decimal?
    /// Сумма уже созданных месячных бюджетов
    private let allocated: Decimal
    private let lastMonthStart: Date
    private let calendar: Calendar

    // MARK: - Init

    init(
        categories: [Category],
        budgetPlans: [BudgetPlan],
        transactions: [Transaction],
        limit: Decimal?,
        now: Date = .now,
        calendar: Calendar = .current
    ) {
        let budgeted = Set(budgetPlans.filter(\.isActive).compactMap { $0.category?.id })
        let currentMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now

        self.categories = categories.filter { $0.type == .expense && !budgeted.contains($0.id) }
        self.history = Self.history(of: transactions, before: currentMonth, calendar: calendar)
        self.limit = limit
        self.allocated = budgetPlans
            .filter { $0.isActive && $0.period == .month && $0.category != nil }
            .reduce(0) { $0 + $1.monthlyLimit }
        self.lastMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        self.calendar = calendar
    }

    // MARK: - Computed Properties

    var amount: Decimal {
        input.amount
    }

    var isAmountEmpty: Bool {
        input.isEmpty
    }

    var selectedCategory: Category? {
        selectedCategoryID.flatMap { id in categories.first { $0.id == id } }
    }

    /// Плитки ленты: больше трат в прошлом месяце — ближе к «Без категории»
    var carouselItems: [CarouselCategory] {
        let month = calendar.component(.month, from: lastMonthStart)

        let items = categories.map { category in
            let spend = lastMonthSpend(of: category.id)

            return CarouselCategory(
                id: category.id,
                title: category.name,
                icon: Image(systemName: category.icon),
                color: DS.CategoryColor(legacyHex: category.colorHex).color,
                monthlySpend: spend,
                spendCaption: spend > 0 ? AppString.addBudgetSpentInMonth(MoneyFormat.money(spend), month: month) : nil
            )
        }
        return CarouselCategory.orderedBySpend(items)
    }

    /// «Октябрь 18 400», «−10% 16 600», «3 мес 19 900». Без категории — без сумм
    var presets: [PresetChip] {
        let values = selectedCategoryID.map(presetValues)

        return [
            PresetChip(id: PresetKind.lastMonth.rawValue, title: lastMonthTitle, amount: values?.lastMonth),
            PresetChip(id: PresetKind.minusTenPercent.rawValue, title: AppString.addBudgetPresetMinusTen, amount: values?.minusTen),
            PresetChip(id: PresetKind.threeMonthAverage.rawValue, title: AppString.addBudgetPresetThreeMonths, amount: values?.average)
        ]
    }

    /// Остаток лимита после этого бюджета; отрицательный — бюджеты больше лимита.
    /// nil — лимит не задан или сумма не введена
    var unallocatedAfterSave: Decimal? {
        guard let limit, !input.isEmpty else { return nil }
        return limit - allocated - amount
    }

    /// Подсказка над кнопкой и выделяемая в ней сумма
    var limitHint: (text: String, highlighted: String)? {
        guard let limit, let rest = unallocatedAfterSave else { return nil }

        let limitText = MoneyFormat.money(limit)
        let restText = MoneyFormat.money(abs(rest))
        let text = rest >= 0
            ? AppString.addBudgetUnallocatedHint(limitText, restText)
            : AppString.addBudgetOverLimitHint(limitText, restText)
        return (text, restText)
    }

    var canSave: Bool {
        selectedCategory != nil && !input.isEmpty
    }

    /// Без категории — «Выберите категорию», без суммы — «Введите сумму»
    var saveButtonTitle: String {
        if selectedCategory == nil { return AppString.selectCategory }
        if input.isEmpty { return AppString.enterAmount }
        return AppString.createBudget
    }

    // MARK: - Actions

    func press(_ key: CalculatorKey) {
        input.press(key)
    }

    func selectPreset(_ value: Decimal) {
        input.set(value)
    }

    func isSelected(_ preset: PresetChip) -> Bool {
        preset.amount.map { $0 > 0 && $0 == amount } ?? false
    }

    /// true — бюджет записан и лист можно закрыть
    func save(using repository: BudgetPlanRepository) -> Bool {
        guard canSave, let category = selectedCategory else { return false }

        do {
            try repository.add(BudgetPlanDraft(
                category: category,
                limit: amount,
                period: period,
                carriesOverRemainder: carriesOverRemainder,
                warnsNearLimit: warnsNearLimit
            ))
            return true
        } catch {
            showingSaveError = true
            return false
        }
    }

    // MARK: - Private Methods

    private func lastMonthSpend(of id: UUID) -> Decimal {
        history[id]?.first ?? 0
    }

    private func presetValues(for id: UUID) -> (lastMonth: Decimal, minusTen: Decimal, average: Decimal) {
        let months = history[id] ?? []
        let lastMonth = months.first ?? 0
        let total = months.reduce(0, +)

        return (
            lastMonth,
            Self.roundedToHundreds(lastMonth * Constants.minusTenFactor),
            Self.roundedToHundreds(total / Decimal(Constants.averageMonths))
        )
    }

    /// «Октябрь» — название прошлого месяца в именительном падеже
    private var lastMonthTitle: String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = Constants.monthFormat
        return formatter.string(from: lastMonthStart).capitalizingFirstLetter
    }

    /// Траты прошлых трех месяцев по категориям; будущие и текущий месяц не считаются
    private static func history(of transactions: [Transaction], before monthStart: Date, calendar: Calendar) -> [UUID: [Decimal]] {
        let starts = (0...Constants.averageMonths).compactMap {
            calendar.date(byAdding: .month, value: -$0, to: monthStart)
        }
        var result: [UUID: [Decimal]] = [:]

        for transaction in transactions where transaction.type == .expense {
            guard let id = transaction.category?.id,
                  let index = (1..<starts.count).first(where: { transaction.date >= starts[$0] && transaction.date < starts[$0 - 1] })
            else { continue }

            result[id, default: Array(repeating: 0, count: Constants.averageMonths)][index - 1] += transaction.amount
        }
        return result
    }

    /// Пресеты от расчетов округляются до сотни: 16 560 → 16 600
    private static func roundedToHundreds(_ value: Decimal) -> Decimal {
        var source = value / Constants.presetStep
        var result = Decimal()
        NSDecimalRound(&result, &source, 0, .plain)
        return result * Constants.presetStep
    }
}

// MARK: - Constants

private extension AddBudgetViewModel {

    enum Constants {
        static let averageMonths = 3
        static let minusTenFactor: Decimal = 0.9
        static let presetStep: Decimal = 100
        static let monthFormat = "LLLL"
    }
}

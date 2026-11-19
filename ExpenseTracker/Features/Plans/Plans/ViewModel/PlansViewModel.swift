//
//  PlansViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI
import SwiftData

@MainActor
@Observable
final class PlansViewModel {

    // MARK: - Properties

    var planToDelete: BudgetPlan?
    var showDeleteAlert = false
    var showingAddPlan = false
    var showingSaveError = false
    var showingMonthlyLimit = false
    var isEditing = false

    let limitStore: MonthlyLimitStore

    /// Текущий момент; подменяется в тестах
    private let now: () -> Date

    private var budgetPlans: [BudgetPlan] = []
    private var transactions: [Transaction] = []
    /// Сдвиг показанного интервала для каждого периода: 0 — текущий, -1 — предыдущий
    private var periodOffsets: [BudgetPeriod: Int] = [:]

    // MARK: - Init

    init(limitStore: MonthlyLimitStore, now: @escaping () -> Date = { .now }) {
        self.limitStore = limitStore
        self.now = now
    }

    // MARK: - Computed Properties

    /// Бюджет без категории — удаленный вместе с ней, но еще не убранный из списка
    var activePlans: [BudgetPlan] {
        budgetPlans.filter { $0.isActive && $0.category != nil }
    }

    var hasPlans: Bool {
        !activePlans.isEmpty
    }

    /// Бюджеты, сгруппированные по периоду: сначала недельные, затем месячные и годовые
    var sections: [BudgetPeriodSection] {
        BudgetPeriod.allCases.compactMap { period in
            let plans = activePlans.filter { $0.period == period }

            guard !plans.isEmpty else { return nil }

            let offset = offset(for: period)

            return BudgetPeriodSection(
                period: period,
                offset: offset,
                title: period.title(offset: offset),
                plans: plans
            )
        }
    }

    /// Общий лимит на текущий месяц; nil — лимит не задан
    var monthlyLimitSummary: MonthlyLimitSummary? {
        guard let limit = limitStore.limit else { return nil }

        return MonthlyLimitSummary(
            limit: limit,
            transactions: transactions,
            monthlyBudgets: activePlans.filter { $0.period == .month },
            now: now()
        )
    }

    // MARK: - Public Methods

    func updateData(budgetPlans: [BudgetPlan], transactions: [Transaction]) {
        self.budgetPlans = budgetPlans
        self.transactions = transactions
    }

    func spentAmount(for plan: BudgetPlan) -> Decimal {
        let interval = plan.period.dateInterval(offset: offset(for: plan.period))

        return transactions
            .filter { transaction in
                transaction.type == .expense &&
                transaction.category?.persistentModelID == plan.category?.persistentModelID &&
                interval.contains(transaction.date)
            }
            .reduce(0) { $0 + $1.amount }
    }

    /// Темп трат по бюджету в показанном интервале: у прошедшего интервала нет отметки «сегодня»
    func pace(for plan: BudgetPlan) -> BudgetPace {
        BudgetPace(
            spent: spentAmount(for: plan),
            limit: plan.monthlyLimit,
            interval: plan.period.dateInterval(offset: offset(for: plan.period)),
            now: now()
        )
    }

    func showMonthlyLimit() {
        showingMonthlyLimit = true
    }

    func offset(for period: BudgetPeriod) -> Int {
        periodOffsets[period] ?? 0
    }

    func goToPreviousPeriod(_ period: BudgetPeriod) {
        changeOffset(for: period, by: -1)
    }

    func goToNextPeriod(_ period: BudgetPeriod) {
        guard offset(for: period) < 0 else { return }
        changeOffset(for: period, by: 1)
    }

    func toggleEditing() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isEditing.toggle()
        }
    }

    func prepareDelete(_ plan: BudgetPlan) {
        planToDelete = plan
        showDeleteAlert = true
    }

    func deletePlan(using repository: BudgetPlanRepository) {
        guard let plan = planToDelete else { return }

        do {
            try withAnimation {
                try repository.delete(plan)
                budgetPlans.removeAll { $0.persistentModelID == plan.persistentModelID }
            }
        } catch {
            showingSaveError = true
        }

        planToDelete = nil

        if !hasPlans {
            isEditing = false
        }
    }

    // MARK: - Private Methods

    private func changeOffset(for period: BudgetPeriod, by value: Int) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            periodOffsets[period, default: 0] += value
        }
    }
}

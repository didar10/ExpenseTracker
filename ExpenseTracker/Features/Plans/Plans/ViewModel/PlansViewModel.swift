//
//  PlansViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI
import SwiftData

@Observable
final class PlansViewModel {

    // MARK: - Properties

    var planToDelete: BudgetPlan?
    var showDeleteAlert = false
    var showingAddPlan = false
    var isEditing = false

    private var budgetPlans: [BudgetPlan] = []
    private var transactions: [Transaction] = []
    /// Сдвиг показанного интервала для каждого периода: 0 — текущий, -1 — предыдущий
    private var periodOffsets: [BudgetPeriod: Int] = [:]

    // MARK: - Computed Properties

    var activePlans: [BudgetPlan] {
        budgetPlans.filter(\.isActive)
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
                transaction.category?.persistentModelID == plan.category.persistentModelID &&
                interval.contains(transaction.date)
            }
            .reduce(0) { $0 + $1.amount }
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

    func deletePlan(context: ModelContext) {
        guard let plan = planToDelete else { return }

        withAnimation {
            budgetPlans.removeAll { $0.persistentModelID == plan.persistentModelID }
            context.delete(plan)
            try? context.save()
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

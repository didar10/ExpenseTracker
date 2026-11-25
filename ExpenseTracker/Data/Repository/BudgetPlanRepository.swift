//
//  BudgetPlanRepository.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation
import SwiftData

/// Новый бюджет: что ввели на листе «Новый бюджет»
struct BudgetPlanDraft {
    let category: Category
    let limit: Decimal
    var period: BudgetPeriod = .month
    var carriesOverRemainder = true
    var warnsNearLimit = true
}

/// Запись бюджетов
@MainActor
protocol BudgetPlanRepository {
    @discardableResult
    func add(_ draft: BudgetPlanDraft) throws -> BudgetPlan
    func delete(_ plan: BudgetPlan) throws
}

@MainActor
struct SwiftDataBudgetPlanRepository: BudgetPlanRepository {

    // MARK: - Properties

    let context: ModelContext

    // MARK: - Methods

    @discardableResult
    func add(_ draft: BudgetPlanDraft) throws -> BudgetPlan {
        let plan = BudgetPlan(
            category: draft.category,
            monthlyLimit: draft.limit,
            period: draft.period,
            carriesOverRemainder: draft.carriesOverRemainder,
            warnsNearLimit: draft.warnsNearLimit
        )
        context.insert(plan)
        try context.saveOrRollback()
        return plan
    }

    func delete(_ plan: BudgetPlan) throws {
        context.delete(plan)
        try context.saveOrRollback()
    }
}

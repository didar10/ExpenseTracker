//
//  BudgetPlanRepository.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation
import SwiftData

/// Запись бюджетов
@MainActor
protocol BudgetPlanRepository {
    @discardableResult
    func add(category: Category, limit: Decimal, period: BudgetPeriod) throws -> BudgetPlan
    func delete(_ plan: BudgetPlan) throws
}

@MainActor
struct SwiftDataBudgetPlanRepository: BudgetPlanRepository {

    // MARK: - Properties

    let context: ModelContext

    // MARK: - Methods

    @discardableResult
    func add(category: Category, limit: Decimal, period: BudgetPeriod) throws -> BudgetPlan {
        let plan = BudgetPlan(category: category, monthlyLimit: limit, period: period)
        context.insert(plan)
        try context.saveOrRollback()
        return plan
    }

    func delete(_ plan: BudgetPlan) throws {
        context.delete(plan)
        try context.saveOrRollback()
    }
}

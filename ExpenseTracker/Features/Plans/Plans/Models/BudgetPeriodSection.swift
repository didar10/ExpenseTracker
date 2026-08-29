//
//  BudgetPeriodSection.swift
//  ExpenseTracker
//
//  Created by Didar on 30.08.2026.
//

import Foundation

/// Группа бюджетов одного периода с текущим сдвигом интервала
struct BudgetPeriodSection: Identifiable {

    // MARK: - Properties

    let period: BudgetPeriod
    /// Сдвиг интервала: 0 — текущий, -1 — предыдущий
    let offset: Int
    let title: String
    let plans: [BudgetPlan]

    // MARK: - Computed Properties

    var id: BudgetPeriod { period }

    /// Вперёд листать можно только пока показан не текущий интервал
    var isNextPeriodAvailable: Bool { offset < 0 }
}

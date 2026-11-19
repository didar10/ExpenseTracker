//
//  MonthlyLimitSummary.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation

/// Общий лимит на текущий месяц на экране «Бюджеты»: сколько потрачено,
/// сколько осталось на день и сколько из лимита распределено по категориям
struct MonthlyLimitSummary: Equatable {

    // MARK: - Properties

    let limit: Decimal
    let spent: Decimal
    /// Может быть отрицательным: это превышение лимита
    let remaining: Decimal
    /// Остаток поровну на оставшиеся дни, включая сегодня; без копеек
    let perDay: Decimal
    /// Сумма месячных бюджетов категорий
    let allocated: Decimal
    let pace: BudgetPace

    // MARK: - Computed Properties

    /// Бюджеты категорий в сумме больше общего лимита
    var isOverAllocated: Bool {
        allocated > limit
    }

    var overAllocation: Decimal {
        max(allocated - limit, 0)
    }

    // MARK: - Init

    init(
        limit: Decimal,
        transactions: [Transaction],
        monthlyBudgets: [BudgetPlan],
        now: Date = .now,
        calendar: Calendar = .current
    ) {
        // Тот же расчет, что на главном: остаток и дни считаются одинаково
        let allowance = DailyAllowance(monthlyLimit: limit, transactions: transactions, now: now, calendar: calendar)
        let month = calendar.dateInterval(of: .month, for: now) ?? DateInterval(start: now, duration: 0)
        let spent = limit - allowance.monthRemaining

        self.limit = limit
        self.spent = spent
        self.remaining = allowance.monthRemaining
        self.perDay = Self.roundedDown(max(allowance.monthRemaining, 0) / Decimal(allowance.daysLeft))
        self.allocated = monthlyBudgets.reduce(0) { $0 + $1.monthlyLimit }
        self.pace = BudgetPace(spent: spent, limit: limit, interval: month, now: now)
    }

    // MARK: - Private Methods

    private static func roundedDown(_ value: Decimal) -> Decimal {
        var source = value
        var result = Decimal()
        NSDecimalRound(&result, &source, 0, .down)
        return result
    }
}

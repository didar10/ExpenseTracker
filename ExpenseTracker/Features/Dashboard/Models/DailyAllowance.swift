//
//  DailyAllowance.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation

/// «Можно потратить сегодня» по месячному лимиту.
///
/// Дневная сумма фиксируется на начало дня: остаток лимита до сегодняшнего дня
/// делится на оставшиеся дни месяца, включая сегодня. Траты за сегодня ее не меняют —
/// уменьшают только остаток дня. Сэкономленное вчера поэтому само переходит
/// на следующие дни, а перерасход уменьшает их
struct DailyAllowance: Equatable {

    enum Status: Equatable {
        /// Укладываемся в сегодняшнюю сумму
        case onTrack
        /// Сегодняшняя сумма потрачена, но месячный лимит еще не превышен
        case overToday
        /// Месячный лимит превышен
        case overMonth
    }

    // MARK: - Properties

    let monthlyLimit: Decimal
    /// Сумма на сегодня, зафиксированная на начало дня
    let todayAllowance: Decimal
    let spentToday: Decimal
    /// Остаток лимита до конца месяца с учетом сегодняшних трат
    let monthRemaining: Decimal
    /// Оставшиеся дни месяца, включая сегодня
    let daysLeft: Int

    // MARK: - Computed Properties

    /// Может быть отрицательным: это перерасход за сегодня
    var todayRemaining: Decimal {
        todayAllowance - spentToday
    }

    var status: Status {
        if monthRemaining < 0 { return .overMonth }
        if todayRemaining < 0 { return .overToday }
        return .onTrack
    }

    /// Доля оставшейся на сегодня суммы, 0...1 — для полоски прогресса
    var todayRemainingFraction: Double {
        guard todayAllowance > 0, todayRemaining > 0 else { return 0 }
        let fraction = NSDecimalNumber(decimal: todayRemaining / todayAllowance).doubleValue
        return min(fraction, 1)
    }

    // MARK: - Init

    init(
        monthlyLimit: Decimal,
        transactions: [Transaction],
        now: Date = .now,
        calendar: Calendar = .current
    ) {
        let startOfToday = calendar.startOfDay(for: now)
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? now
        let month = calendar.dateInterval(of: .month, for: now)
            ?? DateInterval(start: startOfToday, end: startOfTomorrow)

        var spentBeforeToday: Decimal = 0
        var spentToday: Decimal = 0

        // Операции с датой в будущем не считаются: они еще не потрачены
        for transaction in transactions where transaction.type == .expense {
            if transaction.date >= month.start, transaction.date < startOfToday {
                spentBeforeToday += transaction.amount
            } else if transaction.date >= startOfToday, transaction.date < startOfTomorrow {
                spentToday += transaction.amount
            }
        }

        let days = calendar.dateComponents([.day], from: startOfToday, to: month.end).day ?? 1
        let daysLeft = max(days, 1)
        let remainingBeforeToday = max(monthlyLimit - spentBeforeToday, 0)

        self.monthlyLimit = monthlyLimit
        self.todayAllowance = Self.roundedDown(remainingBeforeToday / Decimal(daysLeft))
        self.spentToday = spentToday
        self.monthRemaining = monthlyLimit - spentBeforeToday - spentToday
        self.daysLeft = daysLeft
    }

    // MARK: - Private Methods

    /// Дневная сумма без копеек и с округлением вниз: так за месяц не выйти за лимит
    private static func roundedDown(_ value: Decimal) -> Decimal {
        var source = value
        var result = Decimal()
        NSDecimalRound(&result, &source, 0, .down)
        return result
    }
}

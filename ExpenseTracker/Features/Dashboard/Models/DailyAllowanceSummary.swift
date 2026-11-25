//
//  DailyAllowanceSummary.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import Foundation

/// Тексты и доля полосы карточки «Можно потратить сегодня» для каждого состояния лимита
struct DailyAllowanceSummary: Equatable {

    // MARK: - Properties

    let allowance: DailyAllowance

    // MARK: - Computed Properties

    var title: String {
        switch allowance.status {
        case .onTrack: return AppString.canSpendToday
        case .overToday: return AppString.overspentToday
        case .overMonth: return AppString.monthlyLimitExceeded
        }
    }

    /// Остаток на сегодня; при перерасходе — его размер, без минуса: заголовок уже говорит о перерасходе
    var headlineAmount: Decimal {
        switch allowance.status {
        case .onTrack: return allowance.todayRemaining
        case .overToday: return -allowance.todayRemaining
        case .overMonth: return -allowance.monthRemaining
        }
    }

    var isOver: Bool {
        allowance.status != .onTrack
    }

    /// «из 11 363» рядом с суммой; при превышении месяца дневной суммы нет
    var allowanceOf: Decimal? {
        allowance.status == .overMonth ? nil : allowance.todayAllowance
    }

    /// Доля потраченного для полосы: за день, а при превышении месяца — за месяц.
    /// Больше 1 — полоса в красной штриховке
    var spentFraction: Double {
        switch allowance.status {
        case .onTrack, .overToday:
            guard allowance.todayAllowance > 0 else { return allowance.spentToday > 0 ? 1 : 0 }
            return Self.double(allowance.spentToday / allowance.todayAllowance)
        case .overMonth:
            guard allowance.monthlyLimit > 0 else { return 1 }
            return Self.double((allowance.monthlyLimit - allowance.monthRemaining) / allowance.monthlyLimit)
        }
    }

    /// «Потрачено 61%»
    var spentText: String {
        AppString.spentPercent(Int((spentFraction * 100).rounded()))
    }

    /// «Осталось 118 050 ₸ · 11 дн.»; при превышении месяца — сам лимит
    var remainingText: String {
        switch allowance.status {
        case .onTrack, .overToday:
            return AppString.monthRemainingDays(MoneyFormat.money(allowance.monthRemaining), allowance.daysLeft)
        case .overMonth:
            return AppString.monthlyLimitFooter(MoneyFormat.money(allowance.monthlyLimit))
        }
    }

    // MARK: - Private Methods

    private static func double(_ value: Decimal) -> Double {
        NSDecimalNumber(decimal: value).doubleValue
    }
}

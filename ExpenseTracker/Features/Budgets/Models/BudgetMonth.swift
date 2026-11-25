//
//  BudgetMonth.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import Foundation

/// Показанный месяц экрана «Бюджеты»: интервал, заголовок и прошедшие дни
struct BudgetMonth: Equatable {

    // MARK: - Properties

    let interval: DateInterval
    let daysInMonth: Int
    /// Оставшиеся дни, включая сегодня; nil — месяц уже закончился
    let daysLeft: Int?

    // MARK: - Computed Properties

    /// Доля месяца, прошедшая к концу сегодняшнего дня, 0…1; nil — месяц закончился
    var elapsedFraction: Double? {
        guard let daysLeft, daysInMonth > 0 else { return nil }
        return Double(daysInMonth - daysLeft + 1) / Double(daysInMonth)
    }

    // MARK: - Init

    /// `offset`: 0 — текущий месяц, −1 — прошлый
    init(offset: Int, now: Date, calendar: Calendar) {
        let shifted = calendar.date(byAdding: .month, value: offset, to: now) ?? now
        let interval = calendar.dateInterval(of: .month, for: shifted) ?? DateInterval(start: now, duration: .zero)

        self.interval = interval
        self.daysInMonth = calendar.range(of: .day, in: .month, for: interval.start)?.count ?? 1

        if interval.contains(now) {
            let startOfToday = calendar.startOfDay(for: now)
            let days = calendar.dateComponents([.day], from: startOfToday, to: interval.end).day ?? 1
            self.daysLeft = max(days, 1)
        } else {
            self.daysLeft = nil
        }
    }

    // MARK: - Methods

    /// «Ноябрь 2026» — всегда с годом, как в макете
    func title(locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = Constants.titleFormat
        return formatter.string(from: interval.start).capitalizingFirstLetter
    }
}

// MARK: - Constants

private extension BudgetMonth {

    enum Constants {
        /// Месяц в именительном падеже и год без «г.»: шаблон локали добавил бы его
        static let titleFormat = "LLLL yyyy"
    }
}

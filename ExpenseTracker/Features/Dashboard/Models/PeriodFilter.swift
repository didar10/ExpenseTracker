//
//  PeriodFilter.swift
//  ExpenseTracker
//
//  Created by Didar on 30.08.2026.
//

import Foundation

/// Фильтр периода для карточки баланса: выбранный период и сдвиг относительно текущего
struct PeriodFilter: Equatable {

    // MARK: - Properties

    private(set) var period: StatisticsPeriod = .allTime
    /// Сдвиг периода: 0 — текущий, -1 — предыдущий
    private(set) var offset: Int = 0

    /// Периоды, доступные на главном экране
    static let availablePeriods: [StatisticsPeriod] = [.week, .month, .year, .allTime]

    // MARK: - Computed Properties

    var title: String {
        period.title(offset: offset)
    }

    var interval: DateInterval {
        period.dateInterval(offset: offset)
    }

    /// Можно ли переключать период стрелками
    var isNavigable: Bool {
        period.isNavigable
    }

    /// Вперед можно двигаться только до текущего периода
    var canGoForward: Bool {
        isNavigable && offset < 0
    }

    // MARK: - Methods

    /// Выбирает период и сбрасывает сдвиг на текущий
    mutating func select(_ period: StatisticsPeriod) {
        self.period = period
        offset = 0
    }

    mutating func goBack() {
        guard isNavigable else { return }
        offset -= 1
    }

    mutating func goForward() {
        guard canGoForward else { return }
        offset += 1
    }
}

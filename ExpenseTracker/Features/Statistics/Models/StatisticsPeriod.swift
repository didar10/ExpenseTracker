//
//  StatisticsPeriod.swift
//  ExpenseTracker
//
//  Created by Didar on 01.02.2026.
//

import Foundation

/// Период для фильтрации статистики
enum StatisticsPeriod: String, CaseIterable, Identifiable {
    case day
    case week
    case month
    case year
    case allTime

    var id: String { rawValue }

    // MARK: - Computed Properties

    var displayName: String {
        switch self {
        case .day: return AppString.periodDay
        case .week: return AppString.periodWeek
        case .month: return AppString.periodMonth
        case .year: return AppString.periodYear
        case .allTime: return AppString.periodAllTime
        }
    }

    /// Календарная единица, на которую период сдвигается стрелками
    var calendarComponent: Calendar.Component? {
        switch self {
        case .day: return .day
        case .week: return .weekOfYear
        case .month: return .month
        case .year: return .year
        case .allTime: return nil
        }
    }

    /// Можно ли переключать период стрелками
    var isNavigable: Bool {
        calendarComponent != nil
    }

    // MARK: - Methods

    /// Интервал периода со сдвигом: 0 — текущий, -1 — предыдущий, 1 — следующий
    func dateInterval(offset: Int = 0) -> DateInterval {
        let calendar = Calendar.current
        let now = Date()

        guard let component = calendarComponent else {
            return DateInterval(start: .distantPast, end: .distantFuture)
        }

        guard let shiftedDate = calendar.date(byAdding: component, value: offset, to: now),
              let interval = calendar.dateInterval(of: component, for: shiftedDate) else {
            return DateInterval(start: now, end: now)
        }

        return interval
    }

    /// Заголовок конкретного периода со сдвигом: «Сегодня», «Август», «2025», …
    func title(offset: Int = 0) -> String {
        let calendar = Calendar.current
        let interval = dateInterval(offset: offset)
        let start = interval.start

        switch self {
        case .day:
            if calendar.isDateInToday(start) { return AppString.today }
            if calendar.isDateInYesterday(start) { return AppString.yesterday }
            let format: Date.FormatStyle = isCurrentYear(start)
                ? .dateTime.day().month(.wide)
                : .dateTime.day().month(.wide).year()
            return capitalizingFirstLetter(start.formatted(format))

        case .week:
            let lastDay = calendar.date(byAdding: .day, value: -1, to: interval.end) ?? start
            let range = start..<max(start, lastDay)
            return capitalizingFirstLetter(range.formatted(.interval.day().month(.abbreviated)))

        case .month:
            let format: Date.FormatStyle = isCurrentYear(start)
                ? .dateTime.month(.wide)
                : .dateTime.month(.wide).year()
            return capitalizingFirstLetter(start.formatted(format))

        case .year:
            return start.formatted(.dateTime.year())

        case .allTime:
            return AppString.periodAllTime
        }
    }

    // MARK: - Private Methods

    /// Поднимает регистр только первой буквы: «август» → «Август», «24—30 авг.» не меняется
    private func capitalizingFirstLetter(_ text: String) -> String {
        guard let first = text.first else { return text }
        return first.uppercased() + text.dropFirst()
    }

    private func isCurrentYear(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.year, from: date) == calendar.component(.year, from: Date())
    }
}

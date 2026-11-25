//
//  TransactionDateRules.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import Foundation

/// Чипы быстрого выбора дня на листе даты
enum QuickDay: Int, CaseIterable, Identifiable {
    case today
    case yesterday
    case dayBeforeYesterday

    // MARK: - Computed Properties

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .today: return AppString.today
        case .yesterday: return AppString.yesterday
        case .dayBeforeYesterday: return AppString.dayBeforeYesterday
        }
    }

    /// На сколько дней назад от сегодня
    fileprivate var daysAgo: Int { rawValue }
}

/// Правила даты операции: будущее недоступно, время меняется шагом 15 минут
/// в пределах дня. `now` и календарь передаются явно — так правила проверяются тестами
struct TransactionDateRules {

    // MARK: - Properties

    let calendar: Calendar
    let now: Date

    static let minuteStep = 15

    // MARK: - Init

    init(calendar: Calendar = .current, now: Date = .now) {
        self.calendar = calendar
        self.now = now
    }

    // MARK: - Quick Days

    func quickDay(of date: Date) -> QuickDay? {
        QuickDay.allCases.first { quickDay in
            guard let day = calendar.date(byAdding: .day, value: -quickDay.daysAgo, to: now) else { return false }
            return calendar.isDate(date, inSameDayAs: day)
        }
    }

    func date(for quickDay: QuickDay, keepingTimeOf date: Date) -> Date {
        let day = calendar.date(byAdding: .day, value: -quickDay.daysAgo, to: now) ?? now
        return self.date(onDay: day, keepingTimeOf: date)
    }

    /// День из календаря со временем прежней даты; будущее время сегодня заменяется на «сейчас»
    func date(onDay day: Date, keepingTimeOf date: Date) -> Date {
        let time = calendar.dateComponents([.hour, .minute], from: date)
        let combined = calendar.date(
            bySettingHour: time.hour ?? .zero,
            minute: time.minute ?? .zero,
            second: .zero,
            of: day
        ) ?? day

        return min(combined, currentMinute)
    }

    // MARK: - Calendar

    func isSelectable(day: Date) -> Bool {
        calendar.startOfDay(for: day) <= calendar.startOfDay(for: now)
    }

    /// Листать вперед можно только до текущего месяца
    func canShowMonth(after month: Date) -> Bool {
        guard let next = calendar.date(byAdding: .month, value: 1, to: monthStart(of: month)) else { return false }
        return next <= now
    }

    func monthStart(of date: Date) -> Date {
        calendar.dateInterval(of: .month, for: date)?.start ?? date
    }

    /// Дни месяца по неделям: nil — пустые клетки до первого числа
    func days(inMonthOf month: Date) -> [Date?] {
        let start = monthStart(of: month)
        guard let range = calendar.range(of: .day, in: .month, for: start) else { return [] }

        let weekday = calendar.component(.weekday, from: start)
        let leading = (weekday - calendar.firstWeekday + Constants.daysInWeek) % Constants.daysInWeek

        let days = range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: start)
        }
        return Array(repeating: nil, count: leading) + days
    }

    /// «Пн … Вс» начиная с первого дня недели календаря
    var weekdaySymbols: [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let first = calendar.firstWeekday - 1
        return Array(symbols[first...] + symbols[..<first])
    }

    // MARK: - Time

    /// Время следующей или предыдущей отметки по 15 минут; nil — шаг выходит за пределы дня
    /// или в будущее
    func steppedTime(of date: Date, forward: Bool) -> Date? {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        let minutes = (parts.hour ?? .zero) * Constants.minutesInHour + (parts.minute ?? .zero)
        let step = Self.minuteStep

        let target = forward
            ? (minutes / step + 1) * step
            : ((minutes - 1) / step) * step

        guard minutes > .zero || forward, target >= .zero, target < Constants.minutesInDay else { return nil }

        let result = calendar.date(
            bySettingHour: target / Constants.minutesInHour,
            minute: target % Constants.minutesInHour,
            second: .zero,
            of: date
        )
        guard let result, result <= now else { return nil }
        return result
    }

    // MARK: - Titles

    /// «Сегодня», «Вчера», «Позавчера», иначе «19 нояб.» (с годом — для прошлых лет)
    func pillTitle(for date: Date) -> String {
        if let quickDay = quickDay(of: date) {
            return quickDay.title
        }

        let sameYear = calendar.isDate(date, equalTo: now, toGranularity: .year)
        var style = Date.FormatStyle(locale: calendar.locale ?? .current, calendar: calendar, timeZone: calendar.timeZone)
            .day()
            .month(.abbreviated)
        if !sameYear {
            style = style.year()
        }
        return date.formatted(style)
    }

    /// «23:56»
    func timeText(for date: Date) -> String {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        return String(format: Constants.timeFormat, parts.hour ?? .zero, parts.minute ?? .zero)
    }

    /// «Ноябрь 2026»
    func monthTitle(for month: Date) -> String {
        let style = Date.FormatStyle(locale: calendar.locale ?? .current, calendar: calendar, timeZone: calendar.timeZone)
            .month(.wide)
            .year()
        return month.formatted(style).capitalizingFirstLetter
    }

    // MARK: - Private

    /// «Сейчас» без секунд: выбранное время показывается с точностью до минуты
    private var currentMinute: Date {
        calendar.dateInterval(of: .minute, for: now)?.start ?? now
    }
}

// MARK: - Constants

private enum Constants {
    static let daysInWeek = 7
    static let minutesInHour = 60
    static let minutesInDay = 24 * 60
    static let timeFormat = "%02d:%02d"
}

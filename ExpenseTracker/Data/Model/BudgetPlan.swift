//
//  BudgetPlan.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import Foundation
import SwiftData

@Model
final class BudgetPlan {
    
    var category: Category
    var monthlyLimit: Decimal
    var period: BudgetPeriod
    var createdAt: Date
    var isActive: Bool
    
    init(
        category: Category,
        monthlyLimit: Decimal,
        period: BudgetPeriod = .month,
        isActive: Bool = true
    ) {
        self.category = category
        self.monthlyLimit = monthlyLimit
        self.period = period
        self.createdAt = Date()
        self.isActive = isActive
    }
}

enum BudgetPeriod: String, Codable, CaseIterable {
    case week = "Неделя"
    case month = "Месяц"
    case year = "Год"

    // MARK: - Computed Properties

    var displayName: String {
        switch self {
        case .week: return AppString.periodWeek
        case .month: return AppString.periodMonth
        case .year: return AppString.periodYear
        }
    }

    /// Календарная единица, на которую период сдвигается стрелками
    var calendarComponent: Calendar.Component {
        switch self {
        case .week: return .weekOfYear
        case .month: return .month
        case .year: return .year
        }
    }

    // MARK: - Methods

    /// Интервал периода со сдвигом: 0 — текущий, -1 — предыдущий, 1 — следующий
    func dateInterval(offset: Int = 0) -> DateInterval {
        let calendar = Calendar.current
        let now = Date()

        guard let shiftedDate = calendar.date(byAdding: calendarComponent, value: offset, to: now),
              let interval = calendar.dateInterval(of: calendarComponent, for: shiftedDate) else {
            return DateInterval(start: now, end: now)
        }

        return interval
    }

    /// Заголовок конкретного интервала со сдвигом: «24—30 авг.», «Август», «2026»
    func title(offset: Int = 0) -> String {
        let calendar = Calendar.current
        let interval = dateInterval(offset: offset)
        let start = interval.start

        switch self {
        case .week:
            let lastDay = calendar.date(byAdding: .day, value: -1, to: interval.end) ?? start
            let range = start..<max(start, lastDay)
            return range.formatted(.interval.day().month(.abbreviated)).capitalizingFirstLetter

        case .month:
            let format: Date.FormatStyle = start.isInCurrentYear
                ? .dateTime.month(.wide)
                : .dateTime.month(.wide).year()
            return start.formatted(format).capitalizingFirstLetter

        case .year:
            return start.formatted(.dateTime.year())
        }
    }
}

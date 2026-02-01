//
//  StatisticsPeriod.swift
//  ExpenseTracker
//
//  Created by Didar on 01.02.2026.
//

import Foundation

/// Период для фильтрации статистики
enum StatisticsPeriod: String, CaseIterable, Identifiable {
    case today = "Сегодня"
    case yesterday = "Вчера"
    case week = "Неделя"
    case month = "Месяц"
    case lastMonth = "Прошлый месяц"
    case year = "Год"
    case lastYear = "Прошлый год"
    case allTime = "Все время"
    
    var id: String { rawValue }
    
    var dateInterval: DateInterval {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .today:
            let start = calendar.startOfDay(for: now)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return DateInterval(start: start, end: end)
            
        case .yesterday:
            let start = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))!
            let end = calendar.startOfDay(for: now)
            return DateInterval(start: start, end: end)
            
        case .week:
            let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start)!
            return DateInterval(start: start, end: end)
            
        case .month:
            return calendar.dateInterval(of: .month, for: now)!
            
        case .lastMonth:
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: now)!
            return calendar.dateInterval(of: .month, for: lastMonth)!
            
        case .year:
            return calendar.dateInterval(of: .year, for: now)!
            
        case .lastYear:
            let lastYear = calendar.date(byAdding: .year, value: -1, to: now)!
            return calendar.dateInterval(of: .year, for: lastYear)!
            
        case .allTime:
            // От далекого прошлого до далекого будущего
            let start = calendar.date(from: DateComponents(year: 2000, month: 1, day: 1))!
            let end = calendar.date(from: DateComponents(year: 2100, month: 1, day: 1))!
            return DateInterval(start: start, end: end)
        }
    }
}

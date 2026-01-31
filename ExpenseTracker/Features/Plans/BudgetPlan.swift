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
    
    var dateInterval: DateInterval {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .week:
            let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start)!
            return DateInterval(start: start, end: end)
            
        case .month:
            return calendar.dateInterval(of: .month, for: now)!
            
        case .year:
            return calendar.dateInterval(of: .year, for: now)!
        }
    }
}

//
//  CategoryStatistic.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import Foundation

/// Модель для хранения статистики по категории
struct CategoryStatistic: Identifiable {
    let id = UUID()
    let category: Category
    let amount: Decimal
    let transactionCount: Int
    
    /// Процент от общей суммы
    func percentage(of total: Decimal) -> Double {
        guard total > 0 else { return 0 }
        return ((amount / total) as NSDecimalNumber).doubleValue
    }
    
    /// Процент в виде строки
    func percentageString(of total: Decimal) -> String {
        let value = Int(percentage(of: total) * 100)
        return "\(value)%"
    }
}

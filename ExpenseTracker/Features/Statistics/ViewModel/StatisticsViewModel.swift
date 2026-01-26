//
//  StatisticsViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import Foundation
import SwiftUI

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

/// ViewModel для экрана статистики
@Observable
final class StatisticsViewModel {
    
    // MARK: - Properties
    
    var selectedPeriod: StatisticsPeriod = .month
    var selectedAccount: Account?
    private(set) var statistics: [CategoryStatistic] = []
    private(set) var totalExpenses: Decimal = 0
    
    private var transactions: [Transaction] = []
    
    // MARK: - Computed Properties
    
    var isEmpty: Bool {
        statistics.isEmpty
    }
    
    var periodInterval: DateInterval {
        selectedPeriod.dateInterval
    }
    
    // MARK: - Methods
    
    /// Обновляет транзакции и пересчитывает статистику
    func updateTransactions(_ transactions: [Transaction]) {
        self.transactions = transactions
        calculateStatistics()
    }
    
    /// Изменяет выбранный счет
    func changeAccount(_ account: Account?) {
        selectedAccount = account
        calculateStatistics()
    }
    
    /// Изменяет выбранный период
    func changePeriod(_ period: StatisticsPeriod) {
        selectedPeriod = period
        calculateStatistics()
    }
    
    /// Возвращает транзакции для конкретной категории
    func transactions(for category: Category) -> [Transaction] {
        expenses.filter { $0.category == category }
    }
    
    // MARK: - Private Methods
    
    private var expenses: [Transaction] {
        transactions.filter {
            $0.type == .expense &&
            periodInterval.contains($0.date) &&
            (selectedAccount == nil || $0.account == selectedAccount)
        }
    }
    
    private func calculateStatistics() {
        // Группируем расходы по категориям
        let grouped = Dictionary(grouping: expenses) { $0.category }
        
        // Создаем статистику для каждой категории
        statistics = grouped.compactMap { category, transactions in
            guard let category else { return nil }
            
            let sum = transactions.reduce(0) { $0 + $1.amount }
            
            return CategoryStatistic(
                category: category,
                amount: sum,
                transactionCount: transactions.count
            )
        }
        .sorted { $0.amount > $1.amount }
        
        // Считаем общую сумму расходов
        totalExpenses = expenses.reduce(0) { $0 + $1.amount }
    }
}

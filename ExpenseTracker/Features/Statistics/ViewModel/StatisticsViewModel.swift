//
//  StatisticsViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import Foundation
import SwiftUI

/// ViewModel для экрана статистики
@Observable
final class StatisticsViewModel {
    
    // MARK: - Properties
    
    var selectedMonth: Date = .now
    private(set) var statistics: [CategoryStatistic] = []
    private(set) var totalExpenses: Decimal = 0
    
    private var transactions: [Transaction] = []
    
    // MARK: - Computed Properties
    
    var isEmpty: Bool {
        statistics.isEmpty
    }
    
    var isCurrentMonth: Bool {
        Calendar.current.isDate(selectedMonth, equalTo: .now, toGranularity: .month)
    }
    
    var selectedMonthTitle: String {
        selectedMonth.formatted(
            Date.FormatStyle()
                .month(.wide)
                .year()
        )
        .capitalized
    }
    
    var selectedMonthInterval: DateInterval {
        Calendar.current.dateInterval(of: .month, for: selectedMonth) ?? 
            DateInterval(start: selectedMonth, end: selectedMonth)
    }
    
    // MARK: - Methods
    
    /// Обновляет транзакции и пересчитывает статистику
    func updateTransactions(_ transactions: [Transaction]) {
        self.transactions = transactions
        calculateStatistics()
    }
    
    /// Изменяет выбранный месяц
    func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(
            byAdding: .month,
            value: value,
            to: selectedMonth
        ) {
            selectedMonth = newDate
            calculateStatistics()
        }
    }
    
    /// Возвращает транзакции для конкретной категории
    func transactions(for category: Category) -> [Transaction] {
        expenses.filter { $0.category == category }
    }
    
    // MARK: - Private Methods
    
    private var expenses: [Transaction] {
        transactions.filter {
            $0.type == .expense &&
            selectedMonthInterval.contains($0.date)
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

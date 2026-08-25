//
//  StatisticsViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import Foundation
import SwiftUI
import SwiftData

/// ViewModel для экрана статистики
@MainActor
@Observable
final class StatisticsViewModel {
    
    // MARK: - Properties
    
    var selectedPeriod: StatisticsPeriod = .month
    var selectedAccount: Account?
    var selectedType: TransactionType = .expense
    private(set) var statistics: [CategoryStatistic] = []
    private(set) var totalAmount: Decimal = 0
    
    private var transactions: [Transaction] = []
    private(set) var accounts: [Account] = []
    
    var modelContext: ModelContext?
    
    // MARK: - Computed Properties
    
    var isEmpty: Bool {
        statistics.isEmpty
    }
    
    var periodInterval: DateInterval {
        selectedPeriod.dateInterval
    }
    
    var totalBalance: Decimal {
        accounts.reduce(0) { $0 + $1.currentBalance }
    }
    
    /// Подпись в центре диаграммы — зависит от выбранного типа операций
    var totalTitle: String {
        selectedType == .income ? AppString.incomes : AppString.expenses
    }
    
    /// Подсказка пустого состояния — зависит от выбранного типа операций
    var emptyStateHint: String {
        selectedType == .income ? AppString.noDataHintIncome : AppString.noDataHint
    }
    
    // MARK: - Initialization
    
    /// Устанавливает ModelContext и загружает данные
    func setup(with modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchData()
    }
    
    // MARK: - Methods
    
    /// Загружает данные из ModelContext
    func fetchData() {
        guard let modelContext = modelContext else { return }
        
        // Загружаем транзакции
        let transactionDescriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        transactions = (try? modelContext.fetch(transactionDescriptor)) ?? []
        
        // Загружаем счета
        let accountDescriptor = FetchDescriptor<Account>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        accounts = (try? modelContext.fetch(accountDescriptor)) ?? []
        
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
    
    /// Изменяет тип операций: доходы или расходы
    func changeType(_ type: TransactionType) {
        selectedType = type
        calculateStatistics()
    }
    
    /// Возвращает транзакции для конкретной категории
    func transactions(for category: Category) -> [Transaction] {
        filteredTransactions.filter { $0.category == category }
    }
    
    // MARK: - Private Methods
    
    /// Операции выбранного типа за выбранный период по выбранному счету
    private var filteredTransactions: [Transaction] {
        transactions.filter {
            $0.type == selectedType &&
            periodInterval.contains($0.date) &&
            (selectedAccount == nil || $0.account == selectedAccount)
        }
    }
    
    private func calculateStatistics() {
        // Группируем операции по категориям
        let grouped = Dictionary(grouping: filteredTransactions) { $0.category }
        
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
        
        // Считаем общую сумму за период
        totalAmount = filteredTransactions.reduce(0) { $0 + $1.amount }
    }
}

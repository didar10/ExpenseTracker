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
    private(set) var periodOffset: Int = 0

    /// Тип операций меняется биндингом из переключателя в шапке,
    /// поэтому пересчет статистики висит на самом свойстве
    var selectedType: TransactionType = .expense {
        didSet {
            guard oldValue != selectedType else { return }
            calculateStatistics()
        }
    }

    private(set) var statistics: [CategoryStatistic] = []
    private(set) var totalAmount: Decimal = 0
    /// Считается при загрузке данных: сумма балансов перебирает все операции счета,
    /// а шапка обращается к ней на каждый проход body
    private(set) var totalBalance: Decimal = 0

    private var transactions: [Transaction] = []
    private(set) var accounts: [Account] = []
    
    var modelContext: ModelContext?

    private let accountSelection: AccountSelectionStore

    // MARK: - Init

    init(accountSelection: AccountSelectionStore) {
        self.accountSelection = accountSelection
    }

    // MARK: - Computed Properties

    /// Выбранный счет общий для вкладок, поэтому хранится в AccountSelectionStore
    var selectedAccount: Account? {
        get { accountSelection.selectedAccount }
        set { accountSelection.selectedAccount = newValue }
    }
    
    var isEmpty: Bool {
        statistics.isEmpty
    }
    
    var periodInterval: DateInterval {
        selectedPeriod.dateInterval(offset: periodOffset)
    }

    /// Заголовок выбранного периода с учетом сдвига: «Сегодня», «Август», «2025», …
    var periodTitle: String {
        selectedPeriod.title(offset: periodOffset)
    }

    /// Доступны ли стрелки переключения периода
    var isPeriodNavigable: Bool {
        selectedPeriod.isNavigable
    }

    /// Вперед можно двигаться только до текущего периода
    var canGoToNextPeriod: Bool {
        isPeriodNavigable && periodOffset < 0
    }
    
    /// Подпись в центре диаграммы — зависит от выбранного типа операций
    var totalTitle: String {
        selectedType == .income ? AppString.incomes : AppString.expenses
    }
    
    /// Подсказка пустого состояния — зависит от выбранного типа операций
    var emptyStateHint: String {
        selectedType == .income ? AppString.noDataHintIncome : AppString.noDataHint
    }

    /// Данных нет из-за фильтра периода, а не потому, что операций нет вовсе:
    /// экран предлагает посмотреть за все время
    var isFilteredByPeriod: Bool {
        selectedPeriod != .allTime
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

        // Счет мог быть удален на другом экране, пока вкладка была неактивна
        accountSelection.removeSelectionIfDeleted(from: accounts)

        totalBalance = accounts.reduce(0) { $0 + $1.currentBalance }

        calculateStatistics()
    }
    
    /// Сбрасывает состояние после удаления всех данных и перезагружает справочники
    func resetAfterDataReset() {
        selectedAccount = nil
        fetchData()
    }
    
    /// Счет хранится в общем сторе и меняется снаружи — экрану остается пересчитать статистику
    func refreshStatistics() {
        calculateStatistics()
    }
    
    /// Изменяет выбранный период и сбрасывает сдвиг на текущий
    func changePeriod(_ period: StatisticsPeriod) {
        selectedPeriod = period
        periodOffset = 0
        calculateStatistics()
    }

    /// Сброс фильтра из пустого состояния: показать статистику за все время
    func resetPeriod() {
        changePeriod(.allTime)
    }

    /// Переключает на предыдущий период: прошлый день, неделю, месяц или год
    func goToPreviousPeriod() {
        guard isPeriodNavigable else { return }
        periodOffset -= 1
        calculateStatistics()
    }

    /// Переключает на следующий период, но не дальше текущего
    func goToNextPeriod() {
        guard canGoToNextPeriod else { return }
        periodOffset += 1
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
        // Фильтр перебирает все операции, поэтому считаем его один раз на пересчет
        let periodTransactions = filteredTransactions

        statistics = Dictionary(grouping: periodTransactions) { $0.category }
            .compactMap { category, transactions in
                guard let category else { return nil }

                return CategoryStatistic(
                    category: category,
                    amount: transactions.reduce(0) { $0 + $1.amount },
                    transactionCount: transactions.count
                )
            }
            .sorted { $0.amount > $1.amount }

        totalAmount = periodTransactions.reduce(0) { $0 + $1.amount }
    }
}

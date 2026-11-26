//
//  DashboardViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 09.04.2026.
//

import Foundation
import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {

    // MARK: - UI State

    @Published var selectedTransaction: Transaction?
    /// «Дублировать»: шаблон для новой операции с сегодняшней датой
    @Published var duplicatedTransaction: Transaction?
    @Published var showingAccountsView = false
    let transactionDeletion = TransactionDeletionState()
    @Published var showingMonthlyLimit = false
    /// Обновляется в полночь: «сегодня» в карточке лимита должно смениться без перезапуска
    @Published private(set) var today = Date.now

    // MARK: - Properties

    private let accountSelection: AccountSelectionStore
    private let periodStore: DashboardPeriodStore
    let limitStore: MonthlyLimitStore

    // MARK: - Init

    init(
        accountSelection: AccountSelectionStore,
        periodStore: DashboardPeriodStore,
        limitStore: MonthlyLimitStore
    ) {
        self.accountSelection = accountSelection
        self.periodStore = periodStore
        self.limitStore = limitStore
    }

    // MARK: - Computed Properties

    /// Выбранный счет общий для вкладок, поэтому хранится в AccountSelectionStore
    var selectedAccount: Account? {
        get { accountSelection.selectedAccount }
        set { accountSelection.selectedAccount = newValue }
    }

    /// Выбранный период переживает переключение вкладок и перезапуск приложения,
    /// поэтому хранится в DashboardPeriodStore
    var periodFilter: PeriodFilter {
        periodStore.filter
    }

    func filteredTransactions(from transactions: [Transaction]) -> [Transaction] {
        guard let selectedAccount else { return transactions }
        return transactions.filter { $0.account?.id == selectedAccount.id }
    }

    /// Все данные экрана считаются за один проход: раньше список операций
    /// фильтровался заново для баланса, для шапки и для секций
    func makeSnapshot(accounts: [Account], transactions: [Transaction]) -> DashboardSnapshot {
        let periodTransactions = periodTransactions(from: transactions)

        return DashboardSnapshot(
            periodBalance: balanceData(
                accounts: accounts,
                transactions: transactions,
                periodTransactions: periodTransactions
            ),
            totalBalance: totalBalanceData(accounts: accounts, transactions: transactions).balance,
            sections: TransactionSection.group(periodTransactions),
            dailyAllowance: dailyAllowance(transactions: transactions)
        )
    }

    /// Лимит общий на все счета, поэтому считается по всем операциям,
    /// а не только по выбранному счету
    func dailyAllowance(transactions: [Transaction]) -> DailyAllowance? {
        guard let limit = limitStore.limit else { return nil }
        return DailyAllowance(monthlyLimit: limit, transactions: transactions, now: today)
    }

    /// Карточку можно скрыть в Настройках. И она не к месту, когда листаются прошлые периоды
    /// или выбрано «Все время»: лимит дневной, а не за всю историю
    var showsDailyAllowance: Bool {
        limitStore.isShownOnDashboard && periodFilter.offset == 0 && periodFilter.period != .allTime
    }

    /// За «Все время» баланс берется со счетов (учитывает начальный остаток),
    /// за конкретный период — считается по операциям этого периода
    func balanceData(
        accounts: [Account],
        transactions: [Transaction],
        periodTransactions: [Transaction]
    ) -> BalanceData {
        guard periodFilter.period == .allTime else {
            return BalanceData(transactions: periodTransactions)
        }

        return totalBalanceData(accounts: accounts, transactions: transactions)
    }

    /// Баланс счетов за все время — для шапки экрана, не зависит от выбранного периода
    func totalBalanceData(accounts: [Account], transactions: [Transaction]) -> BalanceData {
        if let selectedAccount {
            return BalanceData(accounts: [selectedAccount])
        } else if !accounts.isEmpty {
            return BalanceData(accounts: accounts)
        } else {
            return BalanceData(transactions: transactions)
        }
    }

    /// Подсказка для пустого списка: за конкретный период предлагать добавить
    /// первую транзакцию некорректно — операций нет только в этом периоде
    var emptyStateHint: String {
        isFilteredByPeriod
            ? AppString.noTransactionsInPeriod(periodFilter.title)
            : AppString.noTransactionsHint
    }

    /// Пустой список из-за фильтра, а не из-за отсутствия операций:
    /// экран предлагает сбросить период, а не добавить первую операцию
    var isFilteredByPeriod: Bool {
        periodFilter.period != .allTime
    }

    // MARK: - Actions

    /// Открывает операцию на редактирование. Анимация не нужна:
    /// у модального экрана своя, а состояние листа анимировать нечем
    func handleTransactionTap(_ transaction: Transaction) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedTransaction = transaction
    }

    /// Сбрасывает выбор, если выбранный счет удалили на другом экране
    func syncSelectedAccount(with accounts: [Account]) {
        accountSelection.removeSelectionIfDeleted(from: accounts)
    }

    func selectAccount(_ account: Account?) {
        withAnimation(Self.animation(DS.Motion.toggle)) {
            selectedAccount = account
        }
        showingAccountsView = false
    }

    func showAccounts() {
        showingAccountsView = true
    }

    func showMonthlyLimit() {
        showingMonthlyLimit = true
    }

    func refreshToday() {
        today = .now
    }

    /// Сброс фильтра из пустого состояния: показать операции за все время
    func resetPeriod() {
        changePeriod(.allTime)
    }

    func changePeriod(_ period: StatisticsPeriod) {
        withAnimation(Self.animation(DS.Motion.toggle)) {
            periodStore.select(period)
        }
    }

    func goToPreviousPeriod() {
        withAnimation(Self.animation(DS.Motion.toggle)) {
            periodStore.goToPreviousPeriod()
        }
    }

    func goToNextPeriod() {
        withAnimation(Self.animation(DS.Motion.toggle)) {
            periodStore.goToNextPeriod()
        }
    }

    /// Открывает новую операцию с суммой, категорией, счетом и заметкой исходной
    /// и сегодняшней датой — для регулярных трат вроде кофе или такси
    func duplicateTransaction(_ transaction: Transaction) {
        duplicatedTransaction = transaction
    }

    // MARK: - Private Methods

    /// «Уменьшить движение» — изменения без анимации
    private static func animation(_ animation: Animation) -> Animation? {
        UIAccessibility.isReduceMotionEnabled ? nil : animation
    }

    /// Операции выбранного счета за выбранный период.
    /// Для «Все время» интервал безграничен, поэтому фильтр по датам ничего не отсекает
    private func periodTransactions(from transactions: [Transaction]) -> [Transaction] {
        let interval = periodFilter.interval
        return filteredTransactions(from: transactions).filter { interval.contains($0.date) }
    }
}

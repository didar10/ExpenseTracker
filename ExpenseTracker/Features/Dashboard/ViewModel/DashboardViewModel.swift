//
//  DashboardViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 09.04.2026.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {

    // MARK: - UI State

    @Published var selectedTransaction: Transaction?
    @Published var showingAccountsView = false
    /// Тост «Отменить» после удаления или повтора операции
    @Published private(set) var undoAction: TransactionUndoAction?
    @Published var showingMonthlyLimit = false
    /// Обновляется в полночь: «сегодня» в карточке лимита должно смениться без перезапуска
    @Published private(set) var today = Date.now

    // MARK: - Properties

    private let accountSelection: AccountSelectionStore
    private let periodStore: DashboardPeriodStore
    let limitStore: MonthlyLimitStore
    private var undoDismissTask: Task<Void, Never>?

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
    var showsDailyAllowance: Bool {
        limitStore.isShownOnDashboard && periodFilter.offset == 0
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
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
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
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            periodStore.select(period)
        }
    }

    func goToPreviousPeriod() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            periodStore.goToPreviousPeriod()
        }
    }

    func goToNextPeriod() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            periodStore.goToNextPeriod()
        }
    }

    /// Удаляет сразу, без подтверждения: ошибку исправляет тост «Отменить»
    func deleteTransaction(_ transaction: Transaction, in context: ModelContext) {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)

        let draft = TransactionDraft(transaction)

        withAnimation(.snappy(duration: 0.25)) {
            context.delete(transaction)
        }
        save(context)

        showUndo(TransactionUndoAction(kind: .deleted(draft)))
    }

    /// Повторяет операцию сегодняшним днем — для регулярных трат вроде кофе или такси
    func repeatTransaction(_ transaction: Transaction, in context: ModelContext) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        let copy = TransactionDraft(transaction).makeTransaction(date: .now)

        withAnimation(.snappy(duration: 0.25)) {
            context.insert(copy)
        }
        save(context)

        showUndo(TransactionUndoAction(kind: .repeated(copy)))
    }

    func undoLastAction(in context: ModelContext) {
        guard let undoAction else { return }

        withAnimation(.snappy(duration: 0.25)) {
            switch undoAction.kind {
            case .deleted(let draft):
                context.insert(draft.makeTransaction())
            case .repeated(let transaction):
                context.delete(transaction)
            }
        }
        save(context)

        dismissUndo()
    }

    func dismissUndo() {
        undoDismissTask?.cancel()
        undoDismissTask = nil

        withAnimation(.snappy(duration: 0.25)) {
            undoAction = nil
        }
    }

    // MARK: - Private Methods

    /// Новое действие заменяет тост предыдущего: отменить можно только последнее
    private func showUndo(_ action: TransactionUndoAction) {
        undoDismissTask?.cancel()

        withAnimation(.snappy(duration: 0.25)) {
            undoAction = action
        }

        undoDismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(Constants.undoVisibleSeconds))
            guard !Task.isCancelled else { return }
            self?.dismissUndo()
        }
    }

    private func save(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            print("Failed to save transaction changes:", error)
        }
    }

    /// Операции выбранного счета за выбранный период.
    /// Для «Все время» интервал безграничен, поэтому фильтр по датам ничего не отсекает
    private func periodTransactions(from transactions: [Transaction]) -> [Transaction] {
        let interval = periodFilter.interval
        return filteredTransactions(from: transactions).filter { interval.contains($0.date) }
    }
}

// MARK: - Constants

private extension DashboardViewModel {

    enum Constants {
        /// Сколько секунд тост ждет отмены
        static let undoVisibleSeconds: Int = 4
    }
}

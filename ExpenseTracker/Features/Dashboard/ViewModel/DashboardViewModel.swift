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
    @Published var showingAccountsView = false

    // MARK: - Properties

    private let accountSelection: AccountSelectionStore
    private let periodStore: DashboardPeriodStore

    // MARK: - Init

    init(accountSelection: AccountSelectionStore, periodStore: DashboardPeriodStore) {
        self.accountSelection = accountSelection
        self.periodStore = periodStore
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

    /// За «Все время» баланс берется со счетов (учитывает начальный остаток),
    /// за конкретный период — считается по операциям этого периода
    func balanceData(accounts: [Account], transactions: [Transaction]) -> BalanceData {
        guard periodFilter.period == .allTime else {
            return BalanceData(transactions: periodTransactions(from: transactions))
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
        periodFilter.period == .allTime
            ? AppString.noTransactionsHint
            : AppString.noTransactionsInPeriod(periodFilter.title)
    }

    func groupedTransactions(from transactions: [Transaction]) -> [TransactionSection] {
        TransactionSection.group(periodTransactions(from: transactions))
    }

    // MARK: - Actions

    func handleTransactionTap(_ transaction: Transaction) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation {
            selectedTransaction = transaction
        }
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

    func hideAccounts() {
        showingAccountsView = false
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

    // MARK: - Private Methods

    /// Операции выбранного счета за выбранный период.
    /// Для «Все время» интервал безграничен, поэтому фильтр по датам ничего не отсекает
    private func periodTransactions(from transactions: [Transaction]) -> [Transaction] {
        let interval = periodFilter.interval
        return filteredTransactions(from: transactions).filter { interval.contains($0.date) }
    }
}

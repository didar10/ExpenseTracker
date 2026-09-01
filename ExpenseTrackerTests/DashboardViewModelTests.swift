//
//  DashboardViewModelTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 01.09.2026.
//

import Foundation
import SwiftData
import Testing
@testable import ExpenseTracker

@MainActor
struct DashboardViewModelTests {

    // MARK: - Helpers

    private func makeContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: Transaction.self, Category.self, Account.self, BudgetPlan.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )

        return ModelContext(container)
    }

    private func makeViewModel(accountSelection: AccountSelectionStore? = nil) -> DashboardViewModel {
        let accountSelection = accountSelection ?? AccountSelectionStore()

        return DashboardViewModel(
            accountSelection: accountSelection,
            periodStore: DashboardPeriodStore(
                defaults: UserDefaults(suiteName: "DashboardViewModelTests.\(UUID().uuidString)")!
            )
        )
    }

    private func date(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now) ?? .now
    }

    // MARK: - Снимок данных

    @Test func snapshotGroupsTransactionsByDay() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 0)
        context.insert(account)

        let today = Transaction(amount: 100, date: .now, type: .expense, account: account)
        let alsoToday = Transaction(amount: 200, date: .now, type: .expense, account: account)
        let yesterday = Transaction(amount: 300, date: date(daysAgo: 1), type: .expense, account: account)

        for transaction in [today, alsoToday, yesterday] {
            context.insert(transaction)
        }

        let viewModel = makeViewModel()
        let snapshot = viewModel.makeSnapshot(
            accounts: [account],
            transactions: [today, alsoToday, yesterday]
        )

        #expect(snapshot.sections.count == 2)
        #expect(snapshot.sections.first?.transactions.count == 2)
        #expect(snapshot.isEmpty == false)
    }

    @Test func snapshotForAllTimeUsesAccountBalance() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let transaction = Transaction(amount: 250, date: .now, type: .expense, account: account)
        context.insert(transaction)

        let viewModel = makeViewModel()
        let snapshot = viewModel.makeSnapshot(accounts: [account], transactions: [transaction])

        // Начальный остаток счета входит в баланс «Все время»
        #expect(snapshot.periodBalance.balance == 750)
        #expect(snapshot.totalBalance == 750)
    }

    @Test func snapshotForPeriodCountsOnlyItsTransactions() throws {
        let context = try makeContext()
        let account = Account(name: "Основной", initialBalance: 1000)
        context.insert(account)

        let recent = Transaction(amount: 250, date: .now, type: .expense, account: account)
        let old = Transaction(amount: 400, date: date(daysAgo: 60), type: .expense, account: account)
        context.insert(recent)
        context.insert(old)

        let viewModel = makeViewModel()
        viewModel.changePeriod(.month)

        let snapshot = viewModel.makeSnapshot(accounts: [account], transactions: [recent, old])

        // За месяц учитывается только свежая операция, начальный остаток не входит
        #expect(snapshot.periodBalance.balance == -250)
        #expect(snapshot.periodBalance.totalExpenses == 250)
        #expect(snapshot.sections.count == 1)
        // Шапка всегда показывает баланс счета за все время
        #expect(snapshot.totalBalance == 350)
    }

    @Test func snapshotKeepsOnlySelectedAccountTransactions() throws {
        let context = try makeContext()
        let card = Account(name: "Карта", initialBalance: 0)
        let cash = Account(name: "Наличные", initialBalance: 0)
        context.insert(card)
        context.insert(cash)

        let cardTransaction = Transaction(amount: 100, date: .now, type: .expense, account: card)
        let cashTransaction = Transaction(amount: 200, date: .now, type: .expense, account: cash)
        context.insert(cardTransaction)
        context.insert(cashTransaction)

        let selection = AccountSelectionStore()
        selection.selectedAccount = card

        let viewModel = makeViewModel(accountSelection: selection)
        let snapshot = viewModel.makeSnapshot(
            accounts: [card, cash],
            transactions: [cardTransaction, cashTransaction]
        )

        #expect(snapshot.sections.first?.transactions.count == 1)
        #expect(snapshot.sections.first?.transactions.first === cardTransaction)
    }

    // MARK: - Пустое состояние

    @Test func emptyStateOffersResetOnlyWhenPeriodFilters() {
        let viewModel = makeViewModel()

        #expect(viewModel.isFilteredByPeriod == false)
        #expect(viewModel.emptyStateHint == AppString.noTransactionsHint)

        viewModel.changePeriod(.month)

        #expect(viewModel.isFilteredByPeriod)
        #expect(viewModel.emptyStateHint != AppString.noTransactionsHint)
    }

    @Test func resetPeriodReturnsToAllTime() {
        let viewModel = makeViewModel()
        viewModel.changePeriod(.week)
        viewModel.goToPreviousPeriod()

        #expect(viewModel.periodFilter.period == .week)

        viewModel.resetPeriod()

        #expect(viewModel.periodFilter.period == .allTime)
        #expect(viewModel.periodFilter.offset == 0)
    }
}

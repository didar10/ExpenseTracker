//
//  StatisticsViewModelTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 01.09.2026.
//

import Foundation
import SwiftData
import Testing
@testable import ExpenseTracker

@MainActor
struct StatisticsViewModelTests {

    // MARK: - Helpers

    private func makeContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: Transaction.self, Category.self, Account.self, BudgetPlan.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )

        return ModelContext(container)
    }

    /// Счет с операциями текущего месяца по двум категориям расходов
    private func makeFilledContext() throws -> (ModelContext, Account, ExpenseTracker.Category, ExpenseTracker.Category) {
        let context = try makeContext()

        let account = Account(name: "Основной", initialBalance: 100_000)
        let food = ExpenseTracker.Category(name: "Еда", icon: "fork.knife", colorHex: "#FF9500")
        let home = ExpenseTracker.Category(name: "Дом", icon: "house.fill", colorHex: "#AF52DE")

        context.insert(account)
        context.insert(food)
        context.insert(home)

        for amount in [Decimal(6_000), Decimal(3_000)] {
            context.insert(
                Transaction(amount: amount, date: .now, type: .expense, category: food, account: account)
            )
        }

        context.insert(
            Transaction(amount: 1_000, date: .now, type: .expense, category: home, account: account)
        )

        context.insert(
            Transaction(amount: 50_000, date: .now, type: .income, category: home, account: account)
        )

        return (context, account, food, home)
    }

    private func makeViewModel(
        context: ModelContext,
        accountSelection: AccountSelectionStore? = nil
    ) -> StatisticsViewModel {
        let viewModel = StatisticsViewModel(accountSelection: accountSelection ?? AccountSelectionStore())
        viewModel.setup(with: context)

        return viewModel
    }

    // MARK: - Расчет статистики

    @Test func statisticsGroupCategoriesAndSortByAmount() throws {
        let (context, _, food, _) = try makeFilledContext()
        let viewModel = makeViewModel(context: context)

        #expect(viewModel.statistics.count == 2)
        #expect(viewModel.statistics.first?.category === food)
        #expect(viewModel.statistics.first?.amount == 9_000)
        #expect(viewModel.statistics.first?.transactionCount == 2)
        #expect(viewModel.totalAmount == 10_000)
    }

    @Test func changingTypeRecalculatesStatistics() throws {
        let (context, _, _, home) = try makeFilledContext()
        let viewModel = makeViewModel(context: context)

        viewModel.selectedType = .income

        #expect(viewModel.statistics.count == 1)
        #expect(viewModel.statistics.first?.category === home)
        #expect(viewModel.totalAmount == 50_000)
    }

    @Test func totalBalanceIsReadyAfterFetch() throws {
        let (context, _, _, _) = try makeFilledContext()
        let viewModel = makeViewModel(context: context)

        // 100 000 начального остатка + 50 000 дохода − 10 000 расходов
        #expect(viewModel.totalBalance == 140_000)
    }

    @Test func transactionsForCategoryKeepPeriodAndTypeFilters() throws {
        let (context, _, food, _) = try makeFilledContext()
        let viewModel = makeViewModel(context: context)

        #expect(viewModel.transactions(for: food).count == 2)
    }

    // MARK: - Идентификаторы

    @Test func statisticIdentityIsStableAcrossRecalculation() throws {
        let (context, _, _, _) = try makeFilledContext()
        let viewModel = makeViewModel(context: context)

        let idsBefore = viewModel.statistics.map(\.id)

        viewModel.refreshStatistics()

        // Идентификатор строки — это категория: пересчет не должен подменять строки списка
        #expect(viewModel.statistics.map(\.id) == idsBefore)
    }

    @Test func statisticIdMatchesCategory() throws {
        let (context, _, food, _) = try makeFilledContext()
        let viewModel = makeViewModel(context: context)

        #expect(viewModel.statistics.first?.id == food.id)
    }

    // MARK: - Проценты

    @Test func percentageIsRoundedNotTruncated() {
        let category = ExpenseTracker.Category(name: "Еда", icon: "fork.knife", colorHex: "#FF9500")
        let statistic = CategoryStatistic(category: category, amount: 9_000, transactionCount: 2)

        // 9000 / 25009 = 35,99 % — отбрасывание дробной части дало бы 35 %
        #expect(statistic.percentageString(of: 25_009) == "36%")
    }

    @Test func percentageIsZeroWithoutTotal() {
        let category = ExpenseTracker.Category(name: "Еда", icon: "fork.knife", colorHex: "#FF9500")
        let statistic = CategoryStatistic(category: category, amount: 100, transactionCount: 1)

        #expect(statistic.percentageString(of: 0) == "0%")
    }

    // MARK: - Период

    @Test func periodFilterFlagAndReset() throws {
        let (context, _, _, _) = try makeFilledContext()
        let viewModel = makeViewModel(context: context)

        #expect(viewModel.isFilteredByPeriod)

        viewModel.resetPeriod()

        #expect(viewModel.selectedPeriod == .allTime)
        #expect(viewModel.isFilteredByPeriod == false)
    }

    @Test func pastPeriodHasNoCurrentTransactions() throws {
        let (context, _, _, _) = try makeFilledContext()
        let viewModel = makeViewModel(context: context)

        viewModel.goToPreviousPeriod()

        #expect(viewModel.isEmpty)
        #expect(viewModel.totalAmount == 0)
    }

    // MARK: - Счет

    @Test func statisticsFollowSelectedAccount() throws {
        let (context, account, _, _) = try makeFilledContext()

        let other = Account(name: "Второй", initialBalance: 0)
        context.insert(other)

        let selection = AccountSelectionStore()
        let viewModel = makeViewModel(context: context, accountSelection: selection)

        selection.selectedAccount = other
        viewModel.refreshStatistics()

        #expect(viewModel.isEmpty)

        selection.selectedAccount = account
        viewModel.refreshStatistics()

        #expect(viewModel.statistics.count == 2)
    }
}

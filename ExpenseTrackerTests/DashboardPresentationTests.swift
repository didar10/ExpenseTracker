//
//  DashboardPresentationTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 25.11.2026.
//

import Foundation
import SwiftData
import Testing
@testable import ExpenseTracker

/// Тексты и числа новой главной: карточка лимита, итог дня, суммы со знаком
@MainActor
struct DashboardPresentationTests {

    // MARK: - Helpers

    private let calendar = Calendar.current

    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: 20, hour: 12)) ?? .now
    }

    private func makeContext() throws -> ModelContext {
        ModelContext(try AppModelContainer.make(inMemory: true))
    }

    /// Лимит 250 000, до сегодня потрачено 125 000: на день 125 000 / 11 = 11 363
    private func allowance(spentToday: Decimal, spentBefore: Decimal = 125_000, in context: ModelContext) -> DailyAllowance {
        let earlier = calendar.date(byAdding: .day, value: -3, to: now) ?? now
        let transactions = [(spentBefore, earlier), (spentToday, now)]
            .filter { $0.0 > 0 }
            .map { ExpenseTracker.Transaction(amount: $0.0, date: $0.1, type: .expense) }
        transactions.forEach(context.insert)

        return DailyAllowance(monthlyLimit: 250_000, transactions: transactions, now: now, calendar: calendar)
    }

    // MARK: - Карточка лимита

    @Test func onTrackMatchesMockup() throws {
        let context = try makeContext()
        let summary = DailyAllowanceSummary(allowance: allowance(spentToday: 6_950, in: context))

        #expect(summary.title == AppString.canSpendToday)
        #expect(summary.headlineAmount == 4_413)
        #expect(summary.allowanceOf == 11_363)
        #expect(summary.spentText == AppString.spentPercent(61))
        #expect(summary.remainingText == AppString.monthRemainingDays(MoneyFormat.money(118_050), 11))
        #expect(!summary.isOver)
    }

    @Test func overspentTodayShowsOverspendAndOverflowingBar() throws {
        let context = try makeContext()
        let summary = DailyAllowanceSummary(allowance: allowance(spentToday: 14_000, in: context))

        #expect(summary.title == AppString.overspentToday)
        #expect(summary.headlineAmount == 2_637)
        #expect(summary.spentFraction > 1)
        #expect(summary.isOver)
    }

    @Test func monthOverLimitHidesDailyAllowance() throws {
        let context = try makeContext()
        let summary = DailyAllowanceSummary(allowance: allowance(spentToday: 20_000, spentBefore: 260_000, in: context))

        #expect(summary.title == AppString.monthlyLimitExceeded)
        #expect(summary.headlineAmount == 30_000)
        #expect(summary.allowanceOf == nil)
        #expect(summary.remainingText == AppString.monthlyLimitFooter(MoneyFormat.money(250_000)))
    }

    // MARK: - Лента

    @Test func dayTotalIsIncomeMinusExpenses() throws {
        let context = try makeContext()
        let transactions = [
            ExpenseTracker.Transaction(amount: 2_100, date: now, type: .expense),
            ExpenseTracker.Transaction(amount: 4_850, date: now, type: .expense),
            ExpenseTracker.Transaction(amount: 480_000, date: now, type: .income)
        ]
        transactions.forEach(context.insert)

        let section = try #require(TransactionSection.group(transactions).first)
        #expect(section.total == 473_050)
        #expect(MoneyFormat.signed(section.total) == "+473\u{00A0}050")
    }

    @Test func rowShowsSignedAmountAndNote() throws {
        let context = try makeContext()
        let expense = ExpenseTracker.Transaction(amount: 2_100, date: now, note: "Такси домой", type: .expense)
        let income = ExpenseTracker.Transaction(amount: 480_000, date: now, note: "", type: .income)
        context.insert(expense)
        context.insert(income)

        let expenseRow = TransactionRowModel(expense)
        #expect(expenseRow.title == AppString.noCategory)
        #expect(expenseRow.subtitle == "Такси домой")
        #expect(expenseRow.amount == "−2\u{00A0}100")
        #expect(!expenseRow.isIncome)

        let incomeRow = TransactionRowModel(income)
        #expect(incomeRow.title == AppString.income)
        #expect(incomeRow.subtitle == nil)
        #expect(incomeRow.amount == "+480\u{00A0}000")
        #expect(incomeRow.isIncome)
    }

    @Test func signedFormatKeepsZeroWithoutSign() {
        #expect(MoneyFormat.signed(0) == "0")
        #expect(MoneyFormat.signed(-131_950) == "−131\u{00A0}950")
    }

    // MARK: - Видимость карточки лимита

    @Test func limitCardHiddenForAllTime() {
        let suite = "DashboardPresentationTests.\(UUID().uuidString)"
        let periodStore = DashboardPeriodStore(defaults: UserDefaults(suiteName: suite) ?? .standard)
        let limitStore = MonthlyLimitStore(defaults: UserDefaults(suiteName: suite + ".limit") ?? .standard)
        let viewModel = DashboardViewModel(
            accountSelection: AccountSelectionStore(),
            periodStore: periodStore,
            limitStore: limitStore
        )

        periodStore.select(.month)
        #expect(viewModel.showsDailyAllowance)

        periodStore.select(.allTime)
        #expect(!viewModel.showsDailyAllowance)
    }
}

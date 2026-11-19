//
//  DailyAllowanceTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 26.10.2026.
//

import Foundation
import Testing
@testable import ExpenseTracker

@MainActor
struct DailyAllowanceTests {

    // MARK: - Helpers

    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Almaty") ?? .current
        return calendar
    }()

    /// Октябрь 2026: 31 день
    private func october(_ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour)) ?? .now
    }

    private func expense(_ amount: Decimal, on date: Date) -> Transaction {
        Transaction(amount: amount, date: date, type: .expense)
    }

    // MARK: - Tests

    @Test func dividesRemainingLimitByDaysLeftIncludingToday() {
        let allowance = DailyAllowance(
            monthlyLimit: 300_000,
            transactions: [expense(210_000, on: october(10)), expense(2_000, on: october(26))],
            now: october(26),
            calendar: calendar
        )

        #expect(allowance.daysLeft == 6)
        #expect(allowance.todayAllowance == 15_000)
        #expect(allowance.todayRemaining == 13_000)
        #expect(allowance.monthRemaining == 88_000)
        #expect(allowance.status == .onTrack)
    }

    @Test func savedAmountCarriesOverToNextDays() {
        // Первого числа ничего не потрачено — второго дневная сумма больше, чем 31 000 / 31
        let allowance = DailyAllowance(
            monthlyLimit: 31_000,
            transactions: [],
            now: october(2),
            calendar: calendar
        )

        #expect(allowance.daysLeft == 30)
        #expect(allowance.todayAllowance == 1_033)
    }

    @Test func todaySpendingDoesNotChangeTodayAllowance() {
        let before = DailyAllowance(monthlyLimit: 300_000, transactions: [], now: october(26), calendar: calendar)
        let after = DailyAllowance(
            monthlyLimit: 300_000,
            transactions: [expense(5_000, on: october(26))],
            now: october(26),
            calendar: calendar
        )

        #expect(before.todayAllowance == after.todayAllowance)
        #expect(after.todayRemaining == before.todayRemaining - 5_000)
    }

    @Test func overspendingTodayKeepsMonthOnTrack() {
        let allowance = DailyAllowance(
            monthlyLimit: 300_000,
            transactions: [expense(210_000, on: october(10)), expense(20_000, on: october(26))],
            now: october(26),
            calendar: calendar
        )

        #expect(allowance.status == .overToday)
        #expect(allowance.todayRemaining == -5_000)
    }

    @Test func exceedingMonthlyLimitIsReported() {
        let allowance = DailyAllowance(
            monthlyLimit: 300_000,
            transactions: [expense(310_000, on: october(10))],
            now: october(26),
            calendar: calendar
        )

        #expect(allowance.status == .overMonth)
        #expect(allowance.todayAllowance == 0)
        #expect(allowance.monthRemaining == -10_000)
    }

    @Test func ignoresIncomePreviousMonthAndFutureExpenses() {
        let september = calendar.date(from: DateComponents(year: 2026, month: 9, day: 30, hour: 12)) ?? .now
        let income = Transaction(amount: 500_000, date: october(5), type: .income)

        let allowance = DailyAllowance(
            monthlyLimit: 310_000,
            transactions: [income, expense(100_000, on: september), expense(50_000, on: october(28))],
            now: october(1),
            calendar: calendar
        )

        #expect(allowance.todayAllowance == 10_000)
        #expect(allowance.monthRemaining == 310_000)
    }
}

//
//  StatisticsPeriodTests.swift
//  ExpenseTrackerTests
//

import Foundation
import Testing
@testable import ExpenseTracker

@Suite
struct StatisticsPeriodTests {

    private let calendar = Calendar.current

    // MARK: - Интервалы

    @Test func currentDayIntervalIsToday() {
        let interval = StatisticsPeriod.day.dateInterval()

        #expect(interval.start == calendar.startOfDay(for: Date()))
        #expect(interval.contains(Date()))
    }

    @Test func previousDayIntervalIsYesterday() {
        let interval = StatisticsPeriod.day.dateInterval(offset: -1)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!

        #expect(interval.contains(yesterday))
        #expect(!interval.contains(Date()))
    }

    @Test func previousWeekIntervalIsShiftedBySevenDays() {
        let current = StatisticsPeriod.week.dateInterval()
        let previous = StatisticsPeriod.week.dateInterval(offset: -1)

        #expect(previous.end == current.start)
        #expect(calendar.dateComponents([.day], from: previous.start, to: current.start).day == 7)
    }

    @Test func previousMonthIntervalIsPreviousCalendarMonth() {
        let previous = StatisticsPeriod.month.dateInterval(offset: -1)
        let expectedStart = calendar.dateInterval(
            of: .month,
            for: calendar.date(byAdding: .month, value: -1, to: Date())!
        )!.start

        #expect(previous.start == expectedStart)
        #expect(previous.end == StatisticsPeriod.month.dateInterval().start)
    }

    @Test func previousYearIntervalIsPreviousCalendarYear() {
        let previous = StatisticsPeriod.year.dateInterval(offset: -1)
        let currentYear = calendar.component(.year, from: Date())

        #expect(calendar.component(.year, from: previous.start) == currentYear - 1)
        #expect(previous.end == StatisticsPeriod.year.dateInterval().start)
    }

    @Test func nextPeriodMovesForward() {
        let previous = StatisticsPeriod.month.dateInterval(offset: -2)
        let next = StatisticsPeriod.month.dateInterval(offset: -1)

        #expect(previous.end == next.start)
    }

    @Test func allTimeIgnoresOffset() {
        let interval = StatisticsPeriod.allTime.dateInterval(offset: -5)

        #expect(interval.contains(Date()))
        #expect(interval == StatisticsPeriod.allTime.dateInterval())
        #expect(!StatisticsPeriod.allTime.isNavigable)
    }

    // MARK: - Заголовки

    @Test func dayTitlesUseRelativeNames() {
        #expect(StatisticsPeriod.day.title() == AppString.today)
        #expect(StatisticsPeriod.day.title(offset: -1) == AppString.yesterday)
        #expect(StatisticsPeriod.day.title(offset: -2) != AppString.yesterday)
    }

    @Test func periodTitlesAreNotEmpty() {
        for period in StatisticsPeriod.allCases {
            #expect(!period.title(offset: -1).isEmpty)
            #expect(!period.displayName.isEmpty)
        }
    }

    @Test func allTimeTitleIsStatic() {
        #expect(StatisticsPeriod.allTime.title(offset: -3) == AppString.periodAllTime)
    }

    @Test func navigablePeriodsCoverEverythingExceptAllTime() {
        #expect(StatisticsPeriod.allCases.filter { $0.isNavigable } == [.day, .week, .month, .year])
    }
}

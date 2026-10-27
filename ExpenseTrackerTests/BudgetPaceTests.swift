//
//  BudgetPaceTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 26.10.2026.
//

import Foundation
import Testing
@testable import ExpenseTracker

struct BudgetPaceTests {

    // MARK: - Helpers

    /// Период в 10 дней: каждый день — 10% времени
    private let interval = DateInterval(start: Date(timeIntervalSince1970: 0), duration: 10 * 86_400)

    private func day(_ value: Double) -> Date {
        interval.start.addingTimeInterval(value * 86_400)
    }

    // MARK: - Tests

    @Test func sameShareSpentLateInPeriodIsOnTrack() {
        let pace = BudgetPace(spent: 60, limit: 100, interval: interval, now: day(6))

        #expect(pace.level == .onTrack)
        #expect(pace.elapsedFraction == 0.6)
    }

    @Test func sameShareSpentEarlyInPeriodIsAhead() {
        let pace = BudgetPace(spent: 60, limit: 100, interval: interval, now: day(2))

        #expect(pace.level == .ahead)
    }

    @Test func smallLeadWithinToleranceIsOnTrack() {
        let pace = BudgetPace(spent: 25, limit: 100, interval: interval, now: day(2))

        #expect(pace.level == .onTrack)
    }

    @Test func exceededLimitIsOverAndProgressIsCapped() {
        let pace = BudgetPace(spent: 150, limit: 100, interval: interval, now: day(9))

        #expect(pace.level == .over)
        #expect(pace.progress == 1)
    }

    @Test func finishedPeriodHasNoTodayMarkerAndIsOnTrackWithinLimit() {
        let pace = BudgetPace(spent: 95, limit: 100, interval: interval, now: day(12))

        #expect(pace.elapsedFraction == nil)
        #expect(pace.level == .onTrack)
    }

    @Test func zeroLimitWithSpendingIsOver() {
        let pace = BudgetPace(spent: 1, limit: 0, interval: interval, now: day(5))

        #expect(pace.level == .over)
    }
}

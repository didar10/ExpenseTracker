//
//  DashboardPeriodStoreTests.swift
//  ExpenseTrackerTests
//

import Foundation
import Testing
@testable import ExpenseTracker

@MainActor
@Suite
struct DashboardPeriodStoreTests {

    // MARK: - Helpers

    /// Отдельное хранилище на каждый тест, чтобы они не влияли друг на друга
    private func makeDefaults() -> UserDefaults {
        UserDefaults(suiteName: "DashboardPeriodStoreTests.\(UUID().uuidString)")!
    }

    // MARK: - Tests

    @Test func defaultPeriodIsAllTime() {
        let store = DashboardPeriodStore(defaults: makeDefaults())

        #expect(store.filter.period == .allTime)
        #expect(store.filter.offset == 0)
    }

    @Test func selectedPeriodIsRestoredOnNextLaunch() {
        let defaults = makeDefaults()

        DashboardPeriodStore(defaults: defaults).select(.month)

        #expect(DashboardPeriodStore(defaults: defaults).filter.period == .month)
    }

    @Test func periodOffsetIsNotRestored() {
        let defaults = makeDefaults()

        let store = DashboardPeriodStore(defaults: defaults)
        store.select(.month)
        store.goToPreviousPeriod()

        #expect(store.filter.offset == -1)
        #expect(DashboardPeriodStore(defaults: defaults).filter.offset == 0)
    }

    @Test func storedPeriodUnavailableOnDashboardIsIgnored() {
        let defaults = makeDefaults()
        defaults.set(StatisticsPeriod.day.rawValue, forKey: "dashboard.selectedPeriod")

        #expect(DashboardPeriodStore(defaults: defaults).filter.period == .allTime)
    }
}

//
//  DashboardPeriodStore.swift
//  ExpenseTracker
//
//  Created by Didar on 30.08.2026.
//

import Foundation

/// Выбранный период главного экрана. Живет на уровне RootTabView, поэтому
/// не сбрасывается при переключении вкладок, и сохраняется между запусками приложения
@MainActor
@Observable
final class DashboardPeriodStore {

    // MARK: - Properties

    private(set) var filter = PeriodFilter()

    @ObservationIgnored
    private let defaults: UserDefaults

    // MARK: - Init

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        restorePeriod()
    }

    // MARK: - Methods

    func select(_ period: StatisticsPeriod) {
        filter.select(period)
        defaults.set(period.rawValue, forKey: Constants.periodKey)
    }

    func goToPreviousPeriod() {
        filter.goBack()
    }

    func goToNextPeriod() {
        filter.goForward()
    }

    // MARK: - Private Methods

    /// Восстанавливает последний выбранный период. Сдвиг намеренно не сохраняем:
    /// «предыдущий месяц» при запуске в другом месяце означал бы уже другой период
    private func restorePeriod() {
        guard let rawValue = defaults.string(forKey: Constants.periodKey),
              let period = StatisticsPeriod(rawValue: rawValue),
              PeriodFilter.availablePeriods.contains(period) else {
            return
        }

        filter.select(period)
    }
}

// MARK: - Constants

private extension DashboardPeriodStore {

    enum Constants {
        static let periodKey = "dashboard.selectedPeriod"
    }
}

//
//  MonthlyLimitStore.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation

/// Общий лимит трат на месяц, из которого считается «Можно потратить сегодня».
/// Живет на уровне RootTabView и сохраняется между запусками приложения
@MainActor
@Observable
final class MonthlyLimitStore {

    // MARK: - Properties

    /// nil — лимит не задан, экран предлагает его задать
    private(set) var limit: Decimal?
    /// Показывать ли карточку лимита на главном экране; настраивается в Настройках
    private(set) var isShownOnDashboard = true

    @ObservationIgnored
    private let defaults: UserDefaults

    // MARK: - Init

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        restoreLimit()
        isShownOnDashboard = defaults.object(forKey: Constants.isShownKey) as? Bool ?? true
    }

    // MARK: - Methods

    /// nil или неположительная сумма убирает лимит
    func setLimit(_ newLimit: Decimal?) {
        guard let newLimit, newLimit > 0 else {
            limit = nil
            defaults.removeObject(forKey: Constants.limitKey)
            return
        }

        limit = newLimit
        // Decimal хранится строкой: через Double теряется точность сумм
        defaults.set(newLimit.description, forKey: Constants.limitKey)
    }

    func setShownOnDashboard(_ isShown: Bool) {
        isShownOnDashboard = isShown
        defaults.set(isShown, forKey: Constants.isShownKey)
    }

    /// После удаления всех данных: лимита нет, карточка снова видна
    func reset() {
        setLimit(nil)
        setShownOnDashboard(true)
    }

    // MARK: - Private Methods

    private func restoreLimit() {
        guard let rawValue = defaults.string(forKey: Constants.limitKey),
              let value = Decimal(string: rawValue),
              value > 0 else {
            return
        }

        limit = value
    }
}

// MARK: - Constants

private extension MonthlyLimitStore {

    enum Constants {
        static let limitKey = "dashboard.monthlyLimit"
        static let isShownKey = "dashboard.isMonthlyLimitShown"
    }
}

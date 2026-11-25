//
//  SettingsViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 23.08.2026.
//

import Foundation

/// ViewModel экрана настроек
@MainActor
@Observable
final class SettingsViewModel {

    // MARK: - Properties

    var showingDeleteAllDataAlert = false
    var showingSaveError = false
    #if DEBUG
    var showingLoadFixtureAlert = false
    #endif

    @ObservationIgnored
    private let limitStore: MonthlyLimitStore

    // MARK: - Init

    init(limitStore: MonthlyLimitStore) {
        self.limitStore = limitStore
    }

    // MARK: - Computed Properties

    var isLimitShownOnDashboard: Bool {
        get { limitStore.isShownOnDashboard }
        set { limitStore.setShownOnDashboard(newValue) }
    }

    /// Версия берется из бандла: строка в ресурсах устаревала бы при каждом релизе
    var appVersionTitle: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        return AppString.appVersion(version ?? "")
    }

    // MARK: - Actions

    func prepareDeleteAllData() {
        showingDeleteAllDataAlert = true
    }

    func cancelDeleteAllData() {
        showingDeleteAllDataAlert = false
    }

    /// Удаляет все пользовательские данные и заново создает значения по умолчанию
    /// - Returns: false — удаление не удалось, данные остались как были
    func confirmDeleteAllData(using repository: AppDataRepository) -> Bool {
        showingDeleteAllDataAlert = false

        do {
            try repository.deleteAllData()
            return true
        } catch {
            showingSaveError = true
            return false
        }
    }

    #if DEBUG
    func prepareLoadFixture() {
        showingLoadFixtureAlert = true
    }

    /// Заменяет все данные фикстурой. Лимит выставляет `applyFixtureLimit(_:)`:
    /// его нужно вызвать после общего сброса экранов, который лимит обнуляет
    /// - Returns: false — загрузка не удалась
    func confirmLoadFixture(_ fixture: Fixture, using repository: AppDataRepository) -> Bool {
        showingLoadFixtureAlert = false

        do {
            try repository.replaceAllData(with: fixture)
            return true
        } catch {
            showingSaveError = true
            return false
        }
    }

    func applyFixtureLimit(_ fixture: Fixture) {
        limitStore.setLimit(fixture.monthlyLimit)
    }
    #endif
}

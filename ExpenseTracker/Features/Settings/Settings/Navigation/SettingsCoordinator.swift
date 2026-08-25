//
//  SettingsCoordinator.swift
//  ExpenseTracker
//
//  Created by Didar on 23.08.2026.
//

import Foundation

/// Экраны, которые открываются из настроек
enum SettingsRoute: Identifiable, Hashable {
    case categories
    case privacyPolicy
    case helpSupport
    case termsOfService

    var id: Self { self }
}

/// Координатор настроек: хранит текущий открытый экран и управляет переходами.
/// View не знает, какой экран стоит за пунктом меню, — только сообщает о намерении.
@MainActor
@Observable
final class SettingsCoordinator {

    // MARK: - Properties

    var activeRoute: SettingsRoute?

    // MARK: - Actions

    func show(_ route: SettingsRoute) {
        activeRoute = route
    }

    func dismiss() {
        activeRoute = nil
    }
}

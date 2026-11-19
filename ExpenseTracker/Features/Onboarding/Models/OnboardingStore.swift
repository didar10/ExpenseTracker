//
//  OnboardingStore.swift
//  ExpenseTracker
//
//  Created by Didar on 03.09.2026.
//

import Foundation

/// Признак пройденного онбординга. Живет на уровне AppRootView и сохраняется
/// между запусками: приветственный экран показывается только при первом открытии
@MainActor
@Observable
final class OnboardingStore {

    // MARK: - Properties

    private(set) var isCompleted: Bool

    @ObservationIgnored
    private let defaults: UserDefaults

    // MARK: - Init

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.isCompleted = defaults.bool(forKey: Constants.completedKey)
    }

    // MARK: - Methods

    func complete() {
        guard !isCompleted else { return }

        isCompleted = true
        defaults.set(true, forKey: Constants.completedKey)
    }
}

// MARK: - Constants

private extension OnboardingStore {

    enum Constants {
        static let completedKey = "onboarding.isCompleted"
    }
}

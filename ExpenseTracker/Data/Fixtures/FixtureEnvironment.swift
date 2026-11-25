//
//  FixtureEnvironment.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

#if DEBUG

import Foundation
import SwiftData
import SwiftUI

/// Изолированное окружение фикстуры для `#Preview` и снапшотов:
/// база в памяти и собственный `UserDefaults`, реальные данные не затрагиваются.
///
/// ```swift
/// #Preview("Данные") {
///     let fixture = FixtureEnvironment(.sample)
///     PlansView(limitStore: fixture.limitStore)
///         .fixture(fixture)
/// }
/// ```
@MainActor
struct FixtureEnvironment {

    // MARK: - Properties

    let fixture: Fixture
    let container: ModelContainer
    let defaults: UserDefaults
    let limitStore: MonthlyLimitStore

    // MARK: - Computed Properties

    var context: ModelContext {
        container.mainContext
    }

    var repositories: Repositories {
        Repositories(context: context)
    }

    // MARK: - Init

    init(_ fixture: Fixture, now: Date = .now) {
        self.fixture = fixture

        let suiteName = "fixture.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("Не удалось создать UserDefaults для фикстуры")
        }
        self.defaults = defaults

        do {
            container = try AppModelContainer.make(inMemory: true)
            try fixture.populate(container.mainContext, now: now)
        } catch {
            fatalError("Не удалось подготовить фикстуру \(fixture): \(error)")
        }

        limitStore = MonthlyLimitStore(defaults: defaults)
        limitStore.setLimit(fixture.monthlyLimit)
    }
}

// MARK: - View

extension View {

    /// Подключает базу фикстуры; репозитории окружения строятся из нее же
    func fixture(_ environment: FixtureEnvironment) -> some View {
        modelContainer(environment.container)
    }
}

#endif

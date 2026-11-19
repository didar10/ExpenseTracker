//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI
import SwiftData

@main
struct ExpenseTrackerApp: App {

    // MARK: - Properties

    /// nil — базу не удалось открыть или перенести на новую схему
    private let modelContainer: ModelContainer?

    // MARK: - Init

    init() {
        NavigationBarAppearance.setup()

        do {
            modelContainer = try AppModelContainer.make()
        } catch {
            // Падение при запуске не дало бы пользователю ничего сделать,
            // а файл базы остается на месте — следующая версия приложения сможет его открыть
            PersistenceLog.logger.fault("Не удалось открыть базу: \(error.localizedDescription, privacy: .public)")
            modelContainer = nil
        }
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            if let modelContainer {
                AppRootView()
                    .modelContainer(modelContainer)
            } else {
                DataUnavailableView()
            }
        }
    }
}

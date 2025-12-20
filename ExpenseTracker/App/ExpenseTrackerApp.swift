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

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [
            Expense.self,
            Category.self
        ])
    }
}

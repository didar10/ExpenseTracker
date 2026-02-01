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
    
    init() {
        NavigationBarAppearance.setup()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [
            Transaction.self,
            Category.self,
            Account.self,
            BudgetPlan.self
        ])
    }
}

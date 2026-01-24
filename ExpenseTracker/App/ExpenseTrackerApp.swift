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
        for family in UIFont.familyNames.sorted() {
            print("📁 \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   └─ \(name)")
            }
        }
        
        NavigationBarAppearance.setup()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [
            Transaction.self,
            Category.self,
            Account.self
        ])
    }
}

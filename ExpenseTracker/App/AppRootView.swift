//
//  AppRootView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI
import SwiftData

struct AppRootView: View {

    @Environment(\.modelContext) private var context

    var body: some View {
        RootTabView()
            .task {
                CategorySeeder.seedIfNeeded(context: context)
            }
    }
}

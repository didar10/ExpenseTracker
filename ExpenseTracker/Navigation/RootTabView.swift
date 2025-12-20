//
//  RootTabView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import Foundation
import SwiftUI

struct RootTabView: View {

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Главная", systemImage: "house")
                }

            StatisticsView()
                .tabItem {
                    Label("Статистика", systemImage: "chart.pie")
                }

            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gear")
                }
        }
    }
}

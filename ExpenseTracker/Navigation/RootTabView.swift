//
//  RootTabView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import Foundation
import SwiftUI

enum TabItem: Hashable {
    case dashboard
    case statistics
    case addPlaceholder
    case plans
    case settings
}


struct RootTabView: View {

    @State private var selectedTab: TabItem = .dashboard
    @State private var isAddPresented = false

    var body: some View {
        ZStack(alignment: .bottom) {

            TabView(selection: $selectedTab) {

                DashboardView()
                    .tag(TabItem.dashboard)
                    .tabItem {
                        Label("Главная", systemImage: "house")
                    }

                StatisticsView()
                    .tag(TabItem.statistics)
                    .tabItem {
                        Label("Статистика", systemImage: "chart.pie")
                    }

                // ❗️ Пустая заглушка под центр
                Color.clear
                    .tag(TabItem.addPlaceholder)
                    .tabItem {
                        Image(systemName: "plus")
                    }

                PlansView()
                    .tag(TabItem.plans)
                    .tabItem {
                        Label("Планы", systemImage: "calendar")
                    }

                SettingsView()
                    .tag(TabItem.settings)
                    .tabItem {
                        Label("Настройки", systemImage: "gear")
                    }
            }
            .tint(Color(hex: "#2CB9B0"))

            centerAddButton
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .addPlaceholder {
                selectedTab = .dashboard
                isAddPresented = true
            }
        }
        .sheet(isPresented: $isAddPresented) {
            NavigationStack {
                AddTransactionView()
            }
        }
    }
}


private extension RootTabView {

    var centerAddButton: some View {
        Button {
            isAddPresented = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(Color(hex: "#2CB9B0"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        }
        .padding(.bottom, 2) // ровно в TabBar
    }
}

//
//  RootTabView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import Foundation
import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: TabItem = .dashboard
    @State private var isAddPresented = false
    @State private var tabBarOffset: CGFloat = 0
    @State private var isTabBarVisible = true
    
    // ViewModels на уровне RootTabView для сохранения состояния между переключениями табов
    @State private var statisticsViewModel = StatisticsViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content views
            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardView()
                        .environment(\.tabBarVisibility, $isTabBarVisible)
                case .statistics:
                    StatisticsView(viewModel: statisticsViewModel)
                        .environment(\.tabBarVisibility, $isTabBarVisible)
                case .plans:
                    PlansView()
                        .environment(\.tabBarVisibility, $isTabBarVisible)
                case .settings:
                    SettingsView(onDataReset: handleDataReset)
                        .environment(\.tabBarVisibility, $isTabBarVisible)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Tab bar and add button
            HStack(alignment: .center, spacing: AppSpacing.medium) {
                // Modern floating tab bar
                ModernTabBar(
                    selectedTab: $selectedTab,
                    isVisible: $isTabBarVisible
                )
                
                // Add button (separate, on the right)
                AddButton(isVisible: $isTabBarVisible) {
                    isAddPresented = true
                }
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.bottom, AppSpacing.small)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $isAddPresented) {
            AddTransactionView()
        }
    }

    // MARK: - Actions

    /// После удаления всех данных возвращаем пользователя на главный экран
    /// и сбрасываем состояние экранов, живущих дольше своей View
    private func handleDataReset() {
        statisticsViewModel.resetAfterDataReset()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedTab = .dashboard
        }
    }
}

// MARK: - Environment Key for Tab Bar Visibility
private struct TabBarVisibilityKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(true)
}

extension EnvironmentValues {
    var tabBarVisibility: Binding<Bool> {
        get { self[TabBarVisibilityKey.self] }
        set { self[TabBarVisibilityKey.self] = newValue }
    }
}

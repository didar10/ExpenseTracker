//
//  RootTabView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: TabItem = .dashboard
    @State private var isAddPresented = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // Состояние на уровне RootTabView сохраняется между переключениями табов:
    // выбранный счет общий для экранов, ViewModel статистики живет дольше своей View
    @State private var accountSelection: AccountSelectionStore
    @State private var dashboardPeriodStore = DashboardPeriodStore()
    @State private var monthlyLimitStore = MonthlyLimitStore()
    @State private var statisticsViewModel: StatisticsViewModel

    init() {
        let accountSelection = AccountSelectionStore()

        _accountSelection = State(initialValue: accountSelection)
        _statisticsViewModel = State(
            initialValue: StatisticsViewModel(accountSelection: accountSelection)
        )
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(
                accountSelection: accountSelection,
                periodStore: dashboardPeriodStore,
                limitStore: monthlyLimitStore,
                onShowStatistics: showStatistics
            )
            .tag(TabItem.dashboard)
            .toolbar(.hidden, for: .tabBar)

            StatisticsView(viewModel: statisticsViewModel)
                .tag(TabItem.statistics)
                .toolbar(.hidden, for: .tabBar)

            PlansView(limitStore: monthlyLimitStore)
                .tag(TabItem.plans)
                .toolbar(.hidden, for: .tabBar)

            SettingsView(limitStore: monthlyLimitStore, onDataReset: handleDataReset)
                .tag(TabItem.settings)
                .toolbar(.hidden, for: .tabBar)
        }
        .floatingTabBar(
            tabs: TabItem.allCases.map(\.floatingTab),
            selection: $selectedTab,
            addAccessibilityLabel: AppString.addTransactionLabel
        ) {
            isAddPresented = true
        }
        .sheet(isPresented: $isAddPresented) {
            AddTransactionView(accountSelection: accountSelection)
        }
    }

    // MARK: - Actions

    /// «Доходы» или «Расходы» на главной открывают статистику этого типа
    private func showStatistics(of type: TransactionType) {
        statisticsViewModel.selectedType = type

        withAnimation(reduceMotion ? nil : DS.Motion.tabSwitch) {
            selectedTab = .statistics
        }
    }

    /// После удаления всех данных возвращаем пользователя на главный экран
    /// и сбрасываем состояние экранов, живущих дольше своей View
    private func handleDataReset() {
        statisticsViewModel.resetAfterDataReset()
        monthlyLimitStore.reset()

        withAnimation(reduceMotion ? nil : DS.Motion.tabSwitch) {
            selectedTab = .dashboard
        }
    }
}

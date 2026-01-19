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
    case plans
    case settings
    
    var title: String {
        switch self {
        case .dashboard: return "Главная"
        case .statistics: return "Статистика"
        case .plans: return "Планы"
        case .settings: return "Настройки"
        }
    }
    
    var icon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .statistics: return "chart.pie.fill"
        case .plans: return "calendar"
        case .settings: return "gearshape.fill"
        }
    }
}

struct RootTabView: View {
    @State private var selectedTab: TabItem = .dashboard
    @State private var isAddPresented = false
    @State private var tabBarOffset: CGFloat = 0
    @State private var isTabBarVisible = true
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content views
            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardView()
                        .environment(\.tabBarVisibility, $isTabBarVisible)
                case .statistics:
                    StatisticsView()
                        .environment(\.tabBarVisibility, $isTabBarVisible)
                case .plans:
                    PlansView()
                        .environment(\.tabBarVisibility, $isTabBarVisible)
                case .settings:
                    SettingsView()
                        .environment(\.tabBarVisibility, $isTabBarVisible)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Tab bar and add button
            HStack(alignment: .bottom, spacing: 12) {
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
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .fullScreenCover(isPresented: $isAddPresented) {
            AddTransactionView()
        }
    }
}

// MARK: - Modern Tab Bar
struct ModernTabBar: View {
    @Binding var selectedTab: TabItem
    @Binding var isVisible: Bool
    
    private let tabs: [TabItem] = [.dashboard, .statistics, .plans, .settings]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
                }
        }
        .offset(y: isVisible ? 0 : 120)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isVisible)
    }
}

// MARK: - Add Button (Separate)
struct AddButton: View {
    @Binding var isVisible: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#2CB9B0"),
                                Color(hex: "#2CB9B0").opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: Color(hex: "#2CB9B0").opacity(0.4), radius: 12, y: 4)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.bottom, 12)
        .offset(y: isVisible ? 0 : 120)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isVisible)
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: isSelected ? 24 : 22, weight: .semibold))
                    .symbolEffect(.bounce, value: isSelected)
                    .foregroundStyle(
                        isSelected
                        ? Color(hex: "#2CB9B0")
                        : .secondary
                    )
                    .frame(height: 24)
                
                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(
                        isSelected
                        ? Color(hex: "#2CB9B0")
                        : .secondary
                    )
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(TabBarButtonStyle())
    }
}

struct TabBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
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

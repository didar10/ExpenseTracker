//
//  ModernTabBar.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

struct ModernTabBar: View {
    @Binding var selectedTab: TabItem
    @Binding var isVisible: Bool
    
    private let tabs: [TabItem] = [.dashboard, .statistics, .plans, .settings]
    
    var body: some View {
        HStack(spacing: 8) {
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
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .offset(y: isVisible ? 0 : 120)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isVisible)
    }
}

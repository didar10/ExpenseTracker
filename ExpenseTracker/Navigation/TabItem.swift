//
//  TabItem.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

enum TabItem: Hashable, CaseIterable {
    case dashboard
    case statistics
    case plans
    case settings

    // MARK: - Computed Properties

    var title: String {
        switch self {
        case .dashboard: return AppString.tabHome
        case .statistics: return AppString.tabStatistics
        case .plans: return AppString.budgets
        case .settings: return AppString.settings
        }
    }

    var icon: Image {
        switch self {
        case .dashboard: return AppImage.tabHome
        case .statistics: return AppImage.tabStatistics
        case .plans: return AppImage.tabBudgets
        case .settings: return AppImage.tabSettings
        }
    }

    var floatingTab: FloatingTab<TabItem> {
        FloatingTab(value: self, icon: icon, title: title)
    }
}

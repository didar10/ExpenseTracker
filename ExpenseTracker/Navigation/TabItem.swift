//
//  TabItem.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import Foundation

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

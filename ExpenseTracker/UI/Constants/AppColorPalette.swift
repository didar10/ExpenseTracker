//
//  AppColorPalette.swift
//  ExpenseTracker
//
//  Created by Didar on 23.08.2026.
//

import SwiftUI

/// Единый маппинг именованных цветов: используется и палитрой выбора, и `Color(named:)`
enum AppColorPalette: String, CaseIterable {

    case blue
    case green
    case orange
    case red
    case purple
    case pink
    case yellow
    case teal
    case indigo
    case brown
    case cyan
    case mint

    // MARK: - Properties

    static let fallback: AppColorPalette = .blue

    static var names: [String] {
        allCases.map(\.rawValue)
    }

    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .orange: return .orange
        case .red: return .red
        case .purple: return .purple
        case .pink: return .pink
        case .yellow: return .yellow
        case .teal: return .teal
        case .indigo: return .indigo
        case .brown: return .brown
        case .cyan: return .cyan
        case .mint: return .mint
        }
    }

    // MARK: - Lookup

    static func color(named name: String) -> Color {
        AppColorPalette(rawValue: name.lowercased())?.color ?? fallback.color
    }
}

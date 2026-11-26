//
//  CategoryTile.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Плитка категории: плоская заливка цвета категории, обводка и иконка цвета ink
struct CategoryTile: View {

    // MARK: - Types

    /// Размеры из макетов: 30 — сводка доходов/расходов, 34 — бюджеты и настройки,
    /// 40 — строка операции, 48 — витрина токенов
    enum Size: CaseIterable {
        case small
        case medium
        case regular
        case large

        var side: CGFloat {
            switch self {
            case .small: return 30
            case .medium: return 34
            case .regular: return 40
            case .large: return 48
            }
        }

        var radius: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 9
            case .regular: return 10
            case .large: return DS.Radius.control
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small, .medium: return DS.Size.iconS
            case .regular: return DS.Size.iconL
            case .large: return DS.Size.iconXL
            }
        }
    }

    // MARK: - Properties

    let icon: Image
    let fill: Color
    let foreground: Color
    var size: Size = .regular

    // MARK: - Init

    init(icon: Image, color: DS.CategoryColor, size: Size = .regular) {
        self.init(icon: icon, fill: color.color, foreground: color.foreground, size: size)
    }

    /// Плитка не из палитры категорий: нейтральная плитка перевода
    init(icon: Image, fill: Color, foreground: Color, size: Size = .regular) {
        self.icon = icon
        self.fill = fill
        self.foreground = foreground
        self.size = size
    }

    // MARK: - Body

    var body: some View {
        icon
            .font(.system(size: size.iconSize, weight: .semibold))
            .foregroundStyle(foreground)
            .frame(width: size.side, height: size.side)
            .background(fill, in: RoundedRectangle(cornerRadius: size.radius))
            .brutalBorder(radius: size.radius)
            .accessibilityHidden(true)
    }
}

// MARK: - Previews

#if DEBUG
private struct CategoryTileGallery: View {

    private let icons = ["cup.and.saucer", "car", "house", "bag", "gift"]

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Цвета") {
                HStack(spacing: DS.Spacing.sm) {
                    ForEach(Array(DS.CategoryColor.allCases.enumerated()), id: \.element) { index, color in
                        CategoryTile(icon: Image(systemName: icons[index]), color: color)
                    }
                }
            }
            DSPreviewCase("Размеры: small · medium · regular · large") {
                HStack(alignment: .bottom, spacing: DS.Spacing.sm) {
                    ForEach(CategoryTile.Size.allCases, id: \.self) { size in
                        CategoryTile(icon: Image(systemName: "cup.and.saucer"), color: .green, size: size)
                    }
                }
            }
        }
    }
}

#Preview("Светлая") {
    CategoryTileGallery()
}

#Preview("Темная") {
    CategoryTileGallery()
        .preferredColorScheme(.dark)
}
#endif

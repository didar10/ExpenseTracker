//
//  AppRadius.swift
//  ExpenseTracker
//
//  Created by Didar on 16.04.2026.
//

import CoreGraphics

/// Правило форм приложения: карточки и первичные кнопки — `card`,
/// вложенные плитки-иконки — `small`, переключатели — капсула.
/// Другие радиусы на одном экране не смешиваем
enum AppRadius {

    // MARK: - Base scale

    static let small: CGFloat = 8
    static let medium: CGFloat = 10
    static let large: CGFloat = 12
    static let button: CGFloat = 14
    static let card: CGFloat = 16
    static let xLarge: CGFloat = 20
}

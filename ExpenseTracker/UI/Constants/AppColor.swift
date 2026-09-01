//
//  AppColor.swift
//  ExpenseTracker
//
//  Created by Didar on 09.04.2026.
//

import SwiftUI

enum AppColor {

    // MARK: - Backgrounds

    static let background = Color.appBackground
    static let cardBackground = Color.appCardBackground
    static let secondaryBackground = Color(uiColor: .secondarySystemGroupedBackground)
    /// Нейтральная подложка внутри карточек: прогресс-бары, вложенные блоки
    static let subtleFill = Color.primary.opacity(0.08)
    /// Светлая нейтральная заливка полей ввода и секций формы
    static let fieldFill = Color.primary.opacity(0.04)
    /// Заливка нейтральных круглых элементов: кнопка «Ещё», плейсхолдеры
    static let neutralFill = Color(uiColor: .systemGray5)
    /// Затемнение под модальными оверлеями
    static let scrim = Color.black.opacity(0.35)

    // MARK: - Semantic

    static let income = Color.green
    static let expense = Color.red
    static let accent = Color.blue
    static let warning = Color.orange
    static let highlight = Color.yellow
    static let decorativePurple = Color.purple

    // MARK: - Text

    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color.gray
    static let textWhite = Color.white
}

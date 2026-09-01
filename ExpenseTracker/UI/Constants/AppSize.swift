//
//  AppSize.swift
//  ExpenseTracker
//
//  Created by Didar on 16.04.2026.
//

import CoreGraphics

enum AppSize {

    // MARK: - Icon containers

    static let iconTiny: CGFloat = 12
    static let iconSmall: CGFloat = 24
    static let iconMedium: CGFloat = 38
    static let iconLarge: CGFloat = 44
    static let iconXLarge: CGFloat = 50
    static let iconXXLarge: CGFloat = 56
    static let iconHuge: CGFloat = 100
    /// Круглая кнопка в шапке экрана
    static let toolbarButton: CGFloat = 40

    // MARK: - Icon glyphs (SF Symbol font sizes)

    static let glyphTiny: CGFloat = 10
    static let glyphSmall: CGFloat = 12
    static let glyphMedium: CGFloat = 14
    static let glyphLarge: CGFloat = 16
    static let glyphXLarge: CGFloat = 20
    static let glyphXXLarge: CGFloat = 24
    static let glyphBig: CGFloat = 26
    static let glyphEmptyState: CGFloat = 48
    static let glyphArrow: CGFloat = 28
    static let glyphHuge: CGFloat = 64

    // MARK: - Controls

    /// Высота клавиши цифровой клавиатуры
    static let keypadKey: CGFloat = 54
    /// Высота первичной кнопки экрана
    static let primaryButton: CGFloat = 56
    /// Высота плитки-поля в строке «счет + дата»
    static let inlineTile: CGFloat = 60
    /// Ширина плитки даты
    static let dateTile: CGFloat = 92
    /// Квадратная плитка иконки внутри карточки
    static let tileIcon: CGFloat = 36
    /// Переключатель «Расход / Доход» в шапке
    static let typePickerWidth: CGFloat = 220
    static let typePickerHeight: CGFloat = 34
    /// Высота шапки экрана
    static let screenHeader: CGFloat = 50
    /// Размер цифры на клавиатуре ввода суммы
    static let keypadDigit: CGFloat = 28
    /// Иконка операции в строке списка
    static let glyphRow: CGFloat = 18

    // MARK: - Elevation

    static let shadowRadius: CGFloat = 10
    static let shadowOffsetY: CGFloat = 4

    // MARK: - Display typography

    /// Размер вводимой суммы на экране операции
    static let amountDisplay: CGFloat = 52

    // MARK: - Charts

    static let chartHeight: CGFloat = 300
    /// Доля внутреннего радиуса «бублика» от внешнего
    static let chartInnerRadiusRatio: CGFloat = 0.6
    /// Доля внешнего радиуса невыделенного сектора
    static let chartOuterRadiusRatio: CGFloat = 0.92
    /// Доля внешнего радиуса выделенного сектора
    static let chartSelectedOuterRadiusRatio: CGFloat = 1
    /// Ширина контента в центре «бублика»
    static let chartCenterContentWidth: CGFloat = 150
}

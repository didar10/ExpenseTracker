//
//  DS+Font.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

extension DS {

    /// Шрифтовые стили. Все масштабируются Dynamic Type относительно ближайшего текстового стиля.
    ///
    /// Unbounded и JetBrains Mono — через `Font.custom(_:size:relativeTo:)`.
    /// SF Pro — системными текстовыми стилями: их базовые размеры совпадают с макетом
    /// (callout 16, footnote 13, caption 12), а `Font.custom` не умеет выбрать системный шрифт по имени
    enum Font {

        // MARK: - Unbounded

        /// Заголовок экрана — Unbounded Bold 28
        static let screenTitle = SwiftUI.Font.custom(FontName.unboundedBold.rawValue, size: Size.screenTitle, relativeTo: .title)
        /// Заголовок листа — Unbounded Bold 22
        static let sheetTitle = SwiftUI.Font.custom(FontName.unboundedBold.rawValue, size: Size.sheetTitle, relativeTo: .title2)
        /// Заголовок алерта и пустого состояния — Unbounded Bold 20
        static let dialogTitle = SwiftUI.Font.custom(FontName.unboundedBold.rawValue, size: Size.dialogTitle, relativeTo: .title3)
        /// Сумма при вводе — Unbounded Bold 48
        static let amountXL = SwiftUI.Font.custom(FontName.unboundedBold.rawValue, size: Size.amountXL, relativeTo: .largeTitle)
        /// Баланс, итоги — Unbounded Bold 40
        static let amountL = SwiftUI.Font.custom(FontName.unboundedBold.rawValue, size: Size.amountL, relativeTo: .largeTitle)

        // MARK: - SF Pro

        /// Основной текст — SF 16
        static let body = SwiftUI.Font.callout
        /// Названия в строках — SF Semibold 16
        static let bodyBold = SwiftUI.Font.callout.weight(.semibold)
        /// Текст алерта и пустого состояния — SF 15
        static let bodySmall = SwiftUI.Font.subheadline
        /// Подписи — SF 13
        static let caption = SwiftUI.Font.footnote
        /// Подписи контролов: пилюля счета, период, поле — SF Semibold 15
        static let control = SwiftUI.Font.subheadline.weight(.semibold)
        /// Сегменты переключателя — SF Bold 15
        static let controlBold = SwiftUI.Font.subheadline.weight(.bold)
        /// Текст главной кнопки — SF Bold 17
        static let button = SwiftUI.Font.body.weight(.bold)
        /// Кнопки алерта — SF Bold 16
        static let buttonSmall = SwiftUI.Font.callout.weight(.bold)
        /// Метки разделов — SF Semibold 12; регистр и разрядку добавляет `.dsLabel()`
        static let label = SwiftUI.Font.caption.weight(.semibold)

        // MARK: - JetBrains Mono

        /// Суммы в списках — JetBrains Mono Bold 15
        static let money = SwiftUI.Font.custom(FontName.jetBrainsMonoBold.rawValue, size: Size.money, relativeTo: .subheadline)
        /// Значение суммы в поле ввода — JetBrains Mono Bold 16
        static let moneyField = SwiftUI.Font.custom(FontName.jetBrainsMonoBold.rawValue, size: Size.moneyField, relativeTo: .callout)
        /// Цифры клавиатуры — JetBrains Mono Medium 24
        static let key = SwiftUI.Font.custom(FontName.jetBrainsMonoMedium.rawValue, size: Size.key, relativeTo: .title2)
        /// Операторы клавиатуры — JetBrains Mono Bold 26
        static let keyOperator = SwiftUI.Font.custom(FontName.jetBrainsMonoBold.rawValue, size: Size.keyOperator, relativeTo: .title2)
        /// Строка выражения калькулятора — JetBrains Mono Medium 15
        static let expression = SwiftUI.Font.custom(FontName.jetBrainsMonoMedium.rawValue, size: Size.expression, relativeTo: .subheadline)
        /// Сумма под категорией в компактной ленте — JetBrains Mono Medium 11
        static let moneyTiny = SwiftUI.Font.custom(FontName.jetBrainsMonoMedium.rawValue, size: Size.moneyTiny, relativeTo: .caption2)
        /// Мелкие суммы и даты — JetBrains Mono Medium 12
        static let moneySmall = SwiftUI.Font.custom(FontName.jetBrainsMonoMedium.rawValue, size: Size.moneySmall, relativeTo: .caption)
    }
}

// MARK: - Sizes

extension DS.Font {

    enum Size {
        static let screenTitle: CGFloat = 28
        static let sheetTitle: CGFloat = 22
        static let dialogTitle: CGFloat = 20
        static let amountXL: CGFloat = 48
        static let amountL: CGFloat = 40
        static let label: CGFloat = 12
        static let money: CGFloat = 15
        static let moneyField: CGFloat = 16
        static let key: CGFloat = 24
        static let keyOperator: CGFloat = 26
        static let expression: CGFloat = 15
        static let moneyTiny: CGFloat = 11
        static let moneySmall: CGFloat = 12
    }

    /// Разрядка метки: 0.06em от 12 pt
    static let labelTracking: CGFloat = Size.label * 0.06
}

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
        /// Сумма при вводе — Unbounded Bold 48
        static let amountXL = SwiftUI.Font.custom(FontName.unboundedBold.rawValue, size: Size.amountXL, relativeTo: .largeTitle)
        /// Баланс, итоги — Unbounded Bold 40
        static let amountL = SwiftUI.Font.custom(FontName.unboundedBold.rawValue, size: Size.amountL, relativeTo: .largeTitle)

        // MARK: - SF Pro

        /// Основной текст — SF 16
        static let body = SwiftUI.Font.callout
        /// Названия в строках — SF Semibold 16
        static let bodyBold = SwiftUI.Font.callout.weight(.semibold)
        /// Подписи — SF 13
        static let caption = SwiftUI.Font.footnote
        /// Метки разделов — SF Semibold 12; регистр и разрядку добавляет `.dsLabel()`
        static let label = SwiftUI.Font.caption.weight(.semibold)

        // MARK: - JetBrains Mono

        /// Суммы в списках — JetBrains Mono Bold 15
        static let money = SwiftUI.Font.custom(FontName.jetBrainsMonoBold.rawValue, size: Size.money, relativeTo: .subheadline)
        /// Мелкие суммы и даты — JetBrains Mono Medium 12
        static let moneySmall = SwiftUI.Font.custom(FontName.jetBrainsMonoMedium.rawValue, size: Size.moneySmall, relativeTo: .caption)
    }
}

// MARK: - Sizes

extension DS.Font {

    enum Size {
        static let screenTitle: CGFloat = 28
        static let sheetTitle: CGFloat = 22
        static let amountXL: CGFloat = 48
        static let amountL: CGFloat = 40
        static let label: CGFloat = 12
        static let money: CGFloat = 15
        static let moneySmall: CGFloat = 12
    }

    /// Разрядка метки: 0.06em от 12 pt
    static let labelTracking: CGFloat = Size.label * 0.06
}

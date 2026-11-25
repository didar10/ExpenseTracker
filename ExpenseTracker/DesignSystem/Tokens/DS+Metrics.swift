//
//  DS+Metrics.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import CoreGraphics

extension DS {

    /// Толщина обводки
    enum Stroke {
        static let regular: CGFloat = 1.5
        /// Обводка нажатого или выбранного элемента
        static let pressed: CGFloat = 2.5
        /// Разделитель строк внутри списка
        static let hairline: CGFloat = 1
        /// Пунктир неактивной кнопки и пустого состояния
        static let dash: [CGFloat] = [4, 3]
    }

    /// Радиусы скругления
    enum Radius {
        /// Кнопки, поля, сегменты
        static let control: CGFloat = 12
        /// Карточки и списки
        static let card: CGFloat = 14
        /// Таббар и кнопка «+»
        static let tabBar: CGFloat = 16
        /// Алерт
        static let dialog: CGFloat = 18
        /// Листы
        static let sheet: CGFloat = 22
    }

    /// Жесткая тень: сплошная, со сдвигом, без размытия.
    /// Только у главных действий — см. CLAUDE.md
    struct Shadow: Equatable {
        let x: CGFloat
        let y: CGFloat
        let radius: CGFloat

        /// Главное действие — 3×3
        static let hard = Shadow(x: 3, y: 3, radius: 0)
        /// Второстепенное — 2×2
        static let hardSmall = Shadow(x: 2, y: 2, radius: 0)
    }

    /// Размеры общих элементов
    enum Size {
        /// Кнопки-иконки, пилюли, период, сегменты
        static let control: CGFloat = 44
        /// Поле ввода
        static let field: CGFloat = 52
        /// Главная кнопка
        static let primaryButton: CGFloat = 56
        /// Строка списка
        static let row: CGFloat = 64
        /// Строка меню, кнопка алерта
        static let menuRow: CGFloat = 50
        /// Панель таббара и кнопка «+»
        static let tabBar: CGFloat = 64
        /// Плашка вкладки
        static let tabItem: CGFloat = 48

        /// Иконки
        static let iconXS: CGFloat = 14
        static let iconS: CGFloat = 16
        static let iconM: CGFloat = 18
        static let iconL: CGFloat = 20
        static let iconXL: CGFloat = 22
        static let iconTab: CGFloat = 24
        static let iconAdd: CGFloat = 28
    }

    /// Шкала отступов
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
    }
}

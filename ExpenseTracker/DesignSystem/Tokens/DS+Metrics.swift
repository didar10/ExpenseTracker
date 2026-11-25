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
    }

    /// Радиусы скругления
    enum Radius {
        /// Кнопки, поля, сегменты
        static let control: CGFloat = 12
        /// Карточки и списки
        static let card: CGFloat = 14
        /// Таббар
        static let tabBar: CGFloat = 16
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

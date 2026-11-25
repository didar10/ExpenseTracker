//
//  DS+Motion.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

extension DS {

    /// Анимации и тайминги отклика
    enum Motion {
        /// Вдавливание кнопки в тень: быстро и без отскока
        static let press = Animation.snappy(duration: 0.08)
        /// Смена состояния контролов: переключатель, сегменты
        static let toggle = Animation.snappy(duration: 0.15)
        /// Появление алерта и меню
        static let overlay = Animation.snappy(duration: 0.2)
        /// Переезд плашки активной вкладки
        static let tabSwitch = Animation.snappy(duration: 0.25)
        /// Минимальное время подсветки при нажатии: быстрый тап иначе не успевает отрисоваться
        static let minimumHighlight = Duration.milliseconds(90)
    }
}

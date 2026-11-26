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
        /// Вдавливание кнопки в тень: лицевая сторона за ~50 мс съезжает на место тени
        static let press = Animation.easeOut(duration: 0.05)
        /// Смена состояния контролов: переключатель, сегменты
        static let toggle = Animation.snappy(duration: 0.15)
        /// Появление алерта и меню
        static let overlay = Animation.snappy(duration: 0.2)
        /// Переезд плашки активной вкладки
        static let tabSwitch = Animation.snappy(duration: 0.25)
        /// «Щелчок обводки»: желтая заливка и обводка 2.5 pt держатся не меньше 90 мс,
        /// иначе быстрый тап не успевает отрисоваться
        static let minimumHighlight = Duration.milliseconds(90)

        /// «Печать суммы»: новая цифра падает сверху с перелетом — `AmountHeaderView`
        enum Print {
            /// Полная длительность появления символа
            static let duration: TimeInterval = 0.16
            /// Доля длительности до нижней точки перелета
            static let overshootShare: Double = 0.7
            static let startOffset: CGFloat = -12
            static let overshoot: CGFloat = 2
            static let startScale: CGFloat = 1.25
            /// «Уменьшить движение»: символ проявляется с этой непрозрачности, без сдвига
            static let reducedStartOpacity: Double = 0.35
        }

        /// ⌫: резкий сдвиг суммы влево и обратно
        enum Erase {
            static let offset: CGFloat = -4
            static let outDuration: TimeInterval = 0.03
            static let backDuration: TimeInterval = 0.06
            /// «Уменьшить движение»: сумма коротко тускнеет вместо сдвига
            static let reducedOpacity: Double = 0.5
        }

        /// Блочный курсор после суммы: шаг 1 с — полсекунды виден, полсекунды скрыт
        static let cursorBlink = Duration.milliseconds(500)
    }
}

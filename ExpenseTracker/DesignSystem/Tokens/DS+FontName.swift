//
//  DS+FontName.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import Foundation

extension DS {

    /// PostScript-имена шрифтов редизайна. Файлы лежат в `DesignSystem/Fonts`
    /// и перечислены в Info.plist (`UIAppFonts`)
    enum FontName: String, CaseIterable {
        /// Заголовки экранов и крупные суммы
        case unboundedMedium = "Unbounded-Medium"
        case unboundedSemiBold = "Unbounded-SemiBold"
        case unboundedBold = "Unbounded-Bold"
        /// Суммы в списках и цифровая клавиатура
        case jetBrainsMonoMedium = "JetBrainsMono-Medium"
        case jetBrainsMonoBold = "JetBrainsMono-Bold"
    }
}

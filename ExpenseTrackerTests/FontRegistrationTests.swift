//
//  FontRegistrationTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 25.11.2026.
//

import CoreText
import Testing
import UIKit
@testable import ExpenseTracker

@MainActor
struct FontRegistrationTests {

    /// Шрифт, не попавший в бандл или в `UIAppFonts`, молча заменяется системным —
    /// тест ловит это до того, как разъедутся макеты
    @Test(arguments: DS.FontName.allCases)
    func fontIsRegistered(_ font: DS.FontName) {
        let uiFont = UIFont(name: font.rawValue, size: Constants.size)

        #expect(uiFont != nil, "Шрифт \(font.rawValue) не найден: проверь DesignSystem/Fonts и UIAppFonts")
        #expect(uiFont?.fontName == font.rawValue)
    }

    /// Интерфейс на русском: у каждого начертания должны быть кириллица и цифры
    @Test(arguments: DS.FontName.allCases)
    func fontCoversCyrillicAndDigits(_ font: DS.FontName) throws {
        try expect(font, covers: Constants.cyrillicAndDigits)
    }

    /// Крупные суммы набираются Unbounded — знак ₸ должен быть в самом шрифте.
    /// В JetBrains Mono его нет: в суммах списков ₸ берется из системного шрифта,
    /// так же, как в макетах (`--mono: "JetBrains Mono", ui-monospace, …`)
    @Test(arguments: [DS.FontName.unboundedMedium, .unboundedSemiBold, .unboundedBold])
    func displayFontHasTengeSign(_ font: DS.FontName) throws {
        try expect(font, covers: Constants.tengeSign)
    }

    // MARK: - Helpers

    private func expect(_ font: DS.FontName, covers text: String) throws {
        let uiFont = try #require(UIFont(name: font.rawValue, size: Constants.size))
        let characters = CTFontCopyCharacterSet(uiFont as CTFont) as CharacterSet

        for scalar in text.unicodeScalars {
            #expect(characters.contains(scalar), "В \(font.rawValue) нет символа «\(scalar)»")
        }
    }
}

// MARK: - Constants

private extension FontRegistrationTests {

    enum Constants {
        static let size: CGFloat = 17
        static let cyrillicAndDigits = "АаЯяЁё0123456789"
        static let tengeSign = "₸"
    }
}

//
//  MonthlyLimitUITests.swift
//  ExpenseTrackerUITests
//
//  Created by Didar on 26.10.2026.
//

import XCTest

/// Проверяет само поле ввода, а не только ViewModel: форматирование проходило
/// тесты логики, но в SwiftUI TextField терялось при быстром наборе
final class MonthlyLimitUITests: XCTestCase {

    // MARK: - Constants

    /// Совпадают с AccessibilityID в приложении
    private enum Identifier {
        static let dailyAllowanceCard = "dashboard.dailyAllowanceCard"
        static let amountField = "monthlyLimit.amountField"
    }

    private let groupingSeparator = "\u{00A0}"
    private let timeout: TimeInterval = 5

    // MARK: - Setup

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Tests

    @MainActor
    func testTypedLimitIsGroupedInField() throws {
        let app = XCUIApplication()
        app.launch()

        let skipOnboarding = app.buttons["Пропустить"]
        if skipOnboarding.waitForExistence(timeout: timeout) {
            skipOnboarding.tap()
        }

        let card = app.buttons[Identifier.dailyAllowanceCard]
        XCTAssertTrue(card.waitForExistence(timeout: timeout))
        card.tap()

        let field = app.textFields[Identifier.amountField]
        XCTAssertTrue(field.waitForExistence(timeout: timeout))
        field.tap()

        // Лимит мог остаться с прошлого запуска — очищаем поле
        if let current = field.value as? String, current.contains(where: \.isNumber), current != "0" {
            field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count))
        }

        // Набор одним махом: SwiftUI TextField на нем терял форматирование («50 0000»)
        field.typeText("500000")

        XCTAssertEqual(field.value as? String, "500\(groupingSeparator)000")

        field.typeText("0")

        XCTAssertEqual(field.value as? String, "5\(groupingSeparator)000\(groupingSeparator)000")

        field.typeText(XCUIKeyboardKey.delete.rawValue)

        XCTAssertEqual(field.value as? String, "500\(groupingSeparator)000")
    }
}

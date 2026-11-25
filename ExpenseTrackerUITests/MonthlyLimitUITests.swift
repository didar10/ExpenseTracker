//
//  MonthlyLimitUITests.swift
//  ExpenseTrackerUITests
//
//  Created by Didar on 26.10.2026.
//

import XCTest

/// Лист «Лимит на месяц» с главной: сумма набирается клавиатурой 3×4 и показывается с разрядами
final class MonthlyLimitUITests: XCTestCase {

    // MARK: - Constants

    /// Совпадают с AccessibilityID в приложении
    private enum Identifier {
        static let dailyAllowanceCard = "dashboard.dailyAllowanceCard"
        static let amount = "monthlyLimit.amount"
    }

    private let groupingSeparator = "\u{00A0}"
    private let timeout: TimeInterval = 5
    /// Больше, чем цифр в самой длинной сумме: стирает лимит с прошлого запуска
    private let clearPresses = 12

    // MARK: - Setup

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Tests

    @MainActor
    func testKeypadInputIsGrouped() throws {
        let app = XCUIApplication()
        app.launch()

        let skipOnboarding = app.buttons["Пропустить"]
        if skipOnboarding.waitForExistence(timeout: timeout) {
            skipOnboarding.tap()
        }

        let card = app.buttons[Identifier.dailyAllowanceCard]
        XCTAssertTrue(card.waitForExistence(timeout: timeout))
        card.tap()

        let backspace = app.buttons["Стереть"]
        XCTAssertTrue(backspace.waitForExistence(timeout: timeout))
        for _ in 0..<clearPresses {
            backspace.tap()
        }

        app.buttons["5"].tap()
        app.buttons["Три нуля"].tap()
        app.buttons["Три нуля"].tap()

        let amount = app.staticTexts[Identifier.amount]
        XCTAssertTrue(amount.label.hasPrefix("5\(groupingSeparator)000\(groupingSeparator)000"))

        backspace.tap()

        XCTAssertTrue(amount.label.hasPrefix("500\(groupingSeparator)000"))
        XCTAssertTrue(app.buttons["Сохранить"].isEnabled)
    }
}

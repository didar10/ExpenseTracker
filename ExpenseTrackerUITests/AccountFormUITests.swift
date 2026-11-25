import XCTest

/// Реальная программная клавиатура: активное поле и кнопка не перекрываются ею.
final class AccountFormUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    @MainActor
    func testKeyboardLeavesFocusedFieldsAndSaveVisible() throws {
        let app = XCUIApplication()
        app.launch()
        let skip = app.buttons["Пропустить"]
        if skip.waitForExistence(timeout: 3) { skip.tap() }

        let picker = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Все счета")).firstMatch
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
        picker.tap()
        let addAccount = app.buttons["accountSelection.add"]
        XCTAssertTrue(addAccount.waitForExistence(timeout: 5))
        addAccount.tap()

        let name = app.textFields["Название"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        let save = app.buttons["accountForm.save"]
        XCTAssertFalse(save.isEnabled)
        name.tap()
        name.typeText("Тестовый счёт")
        assertVisibleAboveKeyboard(name, save: save, app: app)
        XCTAssertTrue(save.isEnabled)

        let balance = app.textFields["Начальный баланс"]
        if !balance.isHittable { app.scrollViews.firstMatch.swipeUp() }
        balance.tap()
        balance.typeText("1234,50")
        assertVisibleAboveKeyboard(balance, save: save, app: app)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Account form with amount keyboard"
        attachment.lifetime = .keepAlways
        add(attachment)

        // Нативный TextField сохраняет ввод и положение курсора до завершения редактирования.
        let done = app.buttons["Готово"]
        XCTAssertTrue(done.waitForExistence(timeout: 3))
        done.tap()
        XCTAssertEqual(balance.value as? String, "1\u{00A0}234,50")
    }

    @MainActor
    private func assertVisibleAboveKeyboard(_ field: XCUIElement, save: XCUIElement, app: XCUIApplication) {
        let keyboard = app.keyboards.firstMatch
        XCTAssertTrue(keyboard.waitForExistence(timeout: 3))
        XCTAssertTrue(field.isHittable)
        XCTAssertTrue(save.isHittable)
        XCTAssertLessThanOrEqual(field.frame.maxY, keyboard.frame.minY + 1)
        XCTAssertLessThanOrEqual(save.frame.maxY, keyboard.frame.minY + 1)
    }
}

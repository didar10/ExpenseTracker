import XCTest

final class SettingsUITests: XCTestCase {
    @MainActor
    func testSettingsToggleResetConfirmationAndDebugMenu() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()

        let skip = app.buttons["Пропустить"]
        if skip.waitForExistence(timeout: 3) { skip.tap() }
        let settings = app.buttons["Настройки"]
        settings.tap()
        XCTAssertTrue(settings.isSelected)
        XCTAssertTrue(app.staticTexts["ExpenseTracker"].exists)
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Settings"
        screenshot.lifetime = .keepAlways
        add(screenshot)

        let toggle = app.switches.firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        let initialValue = toggle.value as? String
        toggle.tap()
        XCTAssertNotEqual(toggle.value as? String, initialValue)
        toggle.tap()
        XCTAssertEqual(toggle.value as? String, initialValue)

        let deleteAll = app.buttons.containing(.staticText, identifier: "Удалить все данные").firstMatch
        deleteAll.tap()
        XCTAssertTrue(app.staticTexts["Удалить все данные?"].waitForExistence(timeout: 5))
        app.buttons["Отмена"].tap()

        let version = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Версия ")).firstMatch
        let versionIsReady = XCTNSPredicateExpectation(predicate: NSPredicate(format: "hittable == true"), object: version)
        XCTAssertEqual(XCTWaiter.wait(for: [versionIsReady], timeout: 5), .completed)
        version.press(forDuration: 0.7)

        let fixture = app.buttons.containing(.staticText, identifier: "Сбросить данные и загрузить фикстуру").firstMatch
        XCTAssertTrue(fixture.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons.containing(.staticText, identifier: "Дизайн-система").firstMatch.exists)
        fixture.tap()
        XCTAssertTrue(app.buttons["Загрузить"].waitForExistence(timeout: 5))
        app.buttons["Отмена"].tap()
    }
}

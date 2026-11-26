import XCTest

final class CategoryManagementUITests: XCTestCase {
    @MainActor
    func testCategoryOpensOperationsAndReorderingSurvivesReopening() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()

        let skip = app.buttons["Пропустить"]
        if skip.waitForExistence(timeout: 3) { skip.tap() }
        app.buttons["Настройки"].tap()

        let categories = app.buttons.containing(.staticText, identifier: "Категории").firstMatch
        categories.tap()

        let home = app.staticTexts["Дом"]
        XCTAssertTrue(home.waitForExistence(timeout: 5))
        home.tap()
        let summary = app.descendants(matching: .any)["categoryTransactions.summary"].firstMatch
        XCTAssertTrue(summary.waitForExistence(timeout: 5))
        app.buttons["categoryTransactions.back"].tap()

        let edit = app.buttons["Изменить"]
        let listIsReady = XCTNSPredicateExpectation(predicate: NSPredicate(format: "hittable == true"), object: edit)
        XCTAssertEqual(XCTWaiter.wait(for: [listIsReady], timeout: 5), .completed)
        edit.tap()
        let food = app.staticTexts["Еда"]
        let homeHandle = app.descendants(matching: .any)["Переместить категорию Дом"].firstMatch
        let foodHandle = app.descendants(matching: .any)["Переместить категорию Еда"].firstMatch
        XCTAssertTrue(homeHandle.waitForExistence(timeout: 5))
        let homeWasFirst = home.frame.midY < food.frame.midY
        homeHandle.press(forDuration: 0.65, thenDragTo: foodHandle)
        XCTAssertEqual(home.frame.midY < food.frame.midY, !homeWasFirst)

        app.buttons["Назад"].tap()
        categories.tap()
        XCTAssertTrue(home.waitForExistence(timeout: 5))
        XCTAssertEqual(home.frame.midY < food.frame.midY, !homeWasFirst)

        app.buttons["Изменить"].tap()
        homeHandle.press(forDuration: 0.65, thenDragTo: foodHandle)
        XCTAssertEqual(home.frame.midY < food.frame.midY, homeWasFirst)
    }
    @MainActor
    func testCategoryFormValidatesNamesAndLocksTypeWhenEditing() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()

        let skip = app.buttons["Пропустить"]
        if skip.waitForExistence(timeout: 3) { skip.tap() }
        app.buttons["Настройки"].tap()
        app.buttons.containing(.staticText, identifier: "Категории").firstMatch.tap()
        app.buttons.containing(.staticText, identifier: "Новая категория").firstMatch.tap()

        let name = app.textFields["Название категории"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        let create = app.buttons["Создать категорию"]
        XCTAssertFalse(create.isEnabled)
        XCTAssertTrue(app.staticTexts["Введите название"].exists)

        name.tap()
        name.typeText("дОМ")
        XCTAssertTrue(app.staticTexts["Категория с таким названием уже есть"].exists)
        XCTAssertFalse(create.isEnabled)
        app.buttons["Закрыть"].tap()
        app.buttons["Не сохранять"].tap()

        let edit = app.buttons["Изменить"]
        let listIsReady = XCTNSPredicateExpectation(predicate: NSPredicate(format: "hittable == true"), object: edit)
        XCTAssertEqual(XCTWaiter.wait(for: [listIsReady], timeout: 5), .completed)
        edit.tap()
        XCTAssertTrue(app.buttons["Готово"].exists)
        app.staticTexts["Дом"].tap()
        XCTAssertTrue(app.staticTexts["Редактировать"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Расход"].isEnabled)
        XCTAssertFalse(app.buttons["Доход"].isEnabled)
        XCTAssertTrue(app.buttons["Сохранить"].isEnabled)
        app.buttons["Удалить категорию?"].tap()
        XCTAssertTrue(app.buttons["Удалить"].waitForExistence(timeout: 5))
        app.buttons["Отмена"].tap()
    }

}

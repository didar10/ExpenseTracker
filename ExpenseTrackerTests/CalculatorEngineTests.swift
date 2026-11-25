//
//  CalculatorEngineTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 25.11.2026.
//

import Foundation
import Testing
@testable import ExpenseTracker

struct CalculatorEngineTests {

    // MARK: - Helpers

    /// Неразрывный пробел — разделитель разрядов в выражении
    private let nbsp = "\u{00A0}"

    /// Вводит строку: цифры, «,», операторы «+ − × ÷» и «⌫»; пробелы пропускаются
    private func engine(_ input: String) -> CalculatorEngine {
        var engine = CalculatorEngine()
        for character in input where character != " " {
            guard let key = CalculatorKey(character) else {
                Issue.record("Неизвестная клавиша «\(character)»")
                continue
            }
            engine.input(key)
        }
        return engine
    }

    private func decimal(_ string: String) -> Decimal? {
        Decimal(string: string, locale: Locale(identifier: "en_US_POSIX"))
    }

    // MARK: - Empty

    @Test func emptyHasNoResultAndNoError() {
        let engine = CalculatorEngine()

        #expect(engine.expressionText.isEmpty)
        #expect(engine.result == nil)
        #expect(engine.error == nil)
        #expect(!engine.hasOperator)
    }

    @Test func operatorAtStartIsIgnored() {
        let engine = engine("+×5")

        #expect(engine.expressionText == "5")
        #expect(engine.result == 5)
    }

    // MARK: - Numbers

    @Test func groupsThousands() {
        #expect(engine("1200").expressionText == "1\(nbsp)200")
        #expect(engine("1234567").expressionText == "1\(nbsp)234\(nbsp)567")
    }

    @Test func leadingZeroIsReplaced() {
        #expect(engine("05").expressionText == "5")
        #expect(engine("00").expressionText == "0")
        #expect(engine("1+07").expressionText == "1 + 7")
    }

    @Test func zeroBeforeCommaIsKept() {
        #expect(engine("0,5").expressionText == "0,5")
        #expect(engine("0,5").result == decimal("0.5"))
    }

    @Test func commaWithoutDigitsStartsWithZero() {
        #expect(engine(",5").expressionText == "0,5")
        #expect(engine("2+,5").expressionText == "2 + 0,5")
    }

    @Test func secondCommaIsIgnored() {
        #expect(engine("1,2,3").expressionText == "1,23")
    }

    @Test func atMostNineDigitsBeforeComma() {
        let engine = engine("1234567890")

        #expect(engine.expressionText == "123\(nbsp)456\(nbsp)789")
        #expect(engine.result == 123_456_789)
    }

    @Test func atMostTwoDigitsAfterComma() {
        let engine = engine("12,345")

        #expect(engine.expressionText == "12,34")
        #expect(engine.result == decimal("12.34"))
    }

    @Test func limitsApplyToEachNumberIndependently() {
        #expect(engine("999999999+1").result == 1_000_000_000)
    }

    // MARK: - Operators

    @Test func expressionText() {
        let engine = engine("1200+800")

        #expect(engine.expressionText == "1\(nbsp)200 + 800")
        #expect(engine.result == 2000)
        #expect(engine.hasOperator)
    }

    @Test func usesTypographicSymbols() {
        #expect(engine("9−3×2÷1").expressionText == "9 − 3 × 2 ÷ 1")
    }

    @Test func secondOperatorReplacesFirst() {
        let engine = engine("5+−×3")

        #expect(engine.expressionText == "5 × 3")
        #expect(engine.result == 15)
    }

    @Test func trailingOperatorIsShownButIgnoredInResult() {
        let engine = engine("1200+")

        #expect(engine.expressionText == "1\(nbsp)200 +")
        #expect(engine.result == 1200)
    }

    @Test func trailingCommaIsDroppedBeforeOperator() {
        #expect(engine("12,+3").expressionText == "12 + 3")
    }

    // MARK: - Precedence

    @Test func multiplicationBeforeAddition() {
        #expect(engine("2+3×4").result == 14)
    }

    @Test func divisionBeforeSubtraction() {
        #expect(engine("20−10÷2").result == 15)
    }

    @Test func leftToRightWithinSamePrecedence() {
        #expect(engine("100÷4×2").result == 50)
        #expect(engine("10−3+2").result == 9)
    }

    @Test func decimalArithmeticIsExact() {
        // Через Double здесь вышло бы 0.30000000000000004
        #expect(engine("0,1+0,2").result == decimal("0.3"))
    }

    @Test func resultIsRoundedToKopecks() {
        #expect(engine("100÷3").result == decimal("33.33"))
        #expect(engine("2÷3").result == decimal("0.67"))
    }

    // MARK: - Errors

    @Test func divisionByZero() {
        let engine = engine("100÷0")

        #expect(engine.error == .divisionByZero)
        #expect(engine.result == nil)
        #expect(engine.error?.message == "На ноль делить нельзя")
    }

    @Test func divisionByZeroInsideLongerExpression() {
        #expect(engine("5+100÷0×3").error == .divisionByZero)
    }

    @Test func divisionByZeroWithCommaIsStillZero() {
        #expect(engine("5÷0,0").error == .divisionByZero)
    }

    @Test func nonPositiveResult() {
        let engine = engine("100−150")

        #expect(engine.error == .nonPositiveResult)
        #expect(engine.error?.message == "Сумма должна быть больше нуля")
        #expect(engine.result == -50)
    }

    @Test func zeroResultOfExpressionIsError() {
        #expect(engine("5−5").error == .nonPositiveResult)
    }

    /// Ноль, набранный без оператора, — еще не введенная сумма, а не ошибка:
    /// экран показывает «0 ₸» и «Введите сумму»
    @Test func plainZeroIsNotAnError() {
        #expect(engine("0").error == nil)
        #expect(engine("0,0").error == nil)
        #expect(engine("0").isValid == false)
    }

    @Test func validResult() {
        #expect(engine("1200+800").isValid)
        #expect(!engine("100÷0").isValid)
        #expect(!CalculatorEngine().isValid)
    }

    // MARK: - Backspace

    @Test func backspaceRemovesLastCharacter() {
        #expect(engine("1234⌫").expressionText == "123")
        #expect(engine("1,5⌫").expressionText == "1,")
        #expect(engine("1,5⌫⌫").expressionText == "1")
    }

    @Test func backspaceRemovesOperator() {
        let engine = engine("12+⌫")

        #expect(engine.expressionText == "12")
        #expect(!engine.hasOperator)
    }

    @Test func backspaceRemovesWholeNumberThenOperator() {
        #expect(engine("12+3⌫").expressionText == "12 +")
        #expect(engine("12+3⌫⌫").expressionText == "12")
    }

    @Test func backspaceOnEmptyDoesNothing() {
        #expect(engine("⌫⌫").expressionText.isEmpty)
    }

    @Test func backspaceClearsError() {
        let engine = engine("100÷0⌫")

        #expect(engine.error == nil)
        #expect(engine.result == 100)
    }
}

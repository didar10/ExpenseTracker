//
//  TransactionFormLogicTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 25.11.2026.
//

import Foundation
import Testing
@testable import ExpenseTracker

/// Логика экрана «Новая операция» без UI: формат сумм, начальная сумма калькулятора,
/// правила выбора даты, траты категорий за месяц и цвет плитки категории
struct TransactionFormLogicTests {

    // MARK: - Helpers

    private let nbsp = "\u{00A0}"

    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Almaty") ?? .current
        calendar.locale = Locale(identifier: "ru_RU")
        calendar.firstWeekday = 2
        return calendar
    }

    private func date(_ day: Int, _ hour: Int, _ minute: Int, month: Int = 11) -> Date {
        Self.calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour, minute: minute)) ?? .distantPast
    }

    private func time(of date: Date) -> String {
        let parts = Self.calendar.dateComponents([.hour, .minute], from: date)
        return String(format: "%02d:%02d", parts.hour ?? -1, parts.minute ?? -1)
    }

    /// «Сейчас» — 25 ноября 2026, 23:56, как в макетах
    private var rules: TransactionDateRules {
        TransactionDateRules(calendar: Self.calendar, now: date(25, 23, 56))
    }

    // MARK: - MoneyFormat

    @Test func groupsThousandsWithNonBreakingSpace() {
        #expect(MoneyFormat.number(4_850) == "4\(nbsp)850")
        #expect(MoneyFormat.number(1_234_567) == "1\(nbsp)234\(nbsp)567")
        #expect(MoneyFormat.number(0) == "0")
    }

    @Test func keepsFractionWithComma() {
        #expect(MoneyFormat.number(Decimal(string: "12.5", locale: Locale(identifier: "en_US_POSIX")) ?? 0) == "12,5")
        #expect(MoneyFormat.number(Decimal(string: "1200.05", locale: Locale(identifier: "en_US_POSIX")) ?? 0) == "1\(nbsp)200,05")
    }

    @Test func negativeUsesTypographicMinus() {
        #expect(MoneyFormat.number(-50) == "−50")
    }

    @Test func moneyAddsTengeSign() {
        #expect(MoneyFormat.money(49_300) == "49\(nbsp)300\(nbsp)₸")
    }

    // MARK: - CalculatorEngine из сохраненной суммы

    @Test func calculatorStartsFromSavedAmount() {
        let engine = CalculatorEngine(amount: 4_850)

        #expect(engine.expressionText == "4\(nbsp)850")
        #expect(engine.result == 4_850)
        #expect(!engine.hasOperator)
    }

    @Test func calculatorStartsFromFractionalAmount() {
        let engine = CalculatorEngine(amount: Decimal(string: "12.5", locale: Locale(identifier: "en_US_POSIX")) ?? 0)

        #expect(engine.expressionText == "12,5")
    }

    @Test func calculatorFromZeroIsEmpty() {
        #expect(CalculatorEngine(amount: 0).expressionText.isEmpty)
    }

    @Test func calculatorFromSavedAmountContinuesTyping() {
        var engine = CalculatorEngine(amount: 100)
        engine.input(.operator(.plus))
        engine.input(.digit(5))

        #expect(engine.result == 105)
    }

    // MARK: - Быстрые дни

    @Test func quickDayRecognizesTodayYesterdayAndDayBefore() {
        #expect(rules.quickDay(of: date(25, 9, 0)) == .today)
        #expect(rules.quickDay(of: date(24, 9, 0)) == .yesterday)
        #expect(rules.quickDay(of: date(23, 9, 0)) == .dayBeforeYesterday)
        #expect(rules.quickDay(of: date(22, 9, 0)) == nil)
    }

    @Test func quickDayKeepsTime() {
        let result = rules.date(for: .yesterday, keepingTimeOf: date(25, 14, 30))

        #expect(Self.calendar.isDate(result, inSameDayAs: date(24, 0, 0)))
        #expect(time(of: result) == "14:30")
    }

    @Test func choosingTodayDoesNotGoIntoFuture() {
        // Время 23:58 вчерашней операции сегодня еще не наступило — берем «сейчас»
        let result = rules.date(for: .today, keepingTimeOf: date(24, 23, 58))

        #expect(result == date(25, 23, 56))
    }

    // MARK: - Календарь

    @Test func futureDaysAreNotSelectable() {
        #expect(rules.isSelectable(day: date(25, 0, 0)))
        #expect(rules.isSelectable(day: date(1, 0, 0)))
        #expect(!rules.isSelectable(day: date(26, 0, 0)))
        #expect(!rules.isSelectable(day: date(1, 0, 0, month: 12)))
    }

    @Test func nextMonthIsUnavailableFromCurrentMonth() {
        #expect(!rules.canShowMonth(after: date(1, 0, 0)))
        #expect(rules.canShowMonth(after: date(1, 0, 0, month: 10)))
    }

    @Test func monthGridStartsOnMonday() {
        // 1 ноября 2026 — воскресенье: шесть пустых клеток перед ним
        let days = rules.days(inMonthOf: date(19, 0, 0))

        #expect(days.prefix(6).allSatisfy { $0 == nil })
        #expect(days[6].map { Self.calendar.component(.day, from: $0) } == 1)
        #expect(days.compactMap { $0 }.count == 30)
    }

    @Test func weekdaySymbolsStartOnMonday() {
        #expect(rules.weekdaySymbols.first?.lowercased() == "пн")
        #expect(rules.weekdaySymbols.count == 7)
    }

    // MARK: - Время шагом 15 минут

    @Test func stepBackSnapsToQuarter() {
        #expect(rules.steppedTime(of: date(25, 23, 56), forward: false).map(time) == "23:45")
        #expect(rules.steppedTime(of: date(20, 10, 45), forward: false).map(time) == "10:30")
    }

    @Test func stepForwardSnapsToQuarter() {
        #expect(rules.steppedTime(of: date(20, 10, 7), forward: true).map(time) == "10:15")
        #expect(rules.steppedTime(of: date(20, 10, 15), forward: true).map(time) == "10:30")
    }

    @Test func stepStaysWithinDay() {
        #expect(rules.steppedTime(of: date(20, 23, 50), forward: true) == nil)
        #expect(rules.steppedTime(of: date(20, 0, 0), forward: false) == nil)
    }

    @Test func stepForwardCannotPassNow() {
        // Сегодня 23:56: из 23:45 шагнуть некуда — 00:00 уже следующий день
        #expect(rules.steppedTime(of: date(25, 23, 45), forward: true) == nil)
        // 23:30 → 23:45 еще в прошлом
        #expect(rules.steppedTime(of: date(25, 23, 30), forward: true).map(time) == "23:45")
    }

    @Test func choosingDayKeepsTimeAndClampsToNow() {
        let past = rules.date(onDay: date(19, 0, 0), keepingTimeOf: date(25, 23, 56))
        #expect(past == date(19, 23, 56))

        let today = rules.date(onDay: date(25, 0, 0), keepingTimeOf: date(19, 23, 59))
        #expect(today == date(25, 23, 56))
    }

    // MARK: - Подписи пилюли даты

    @Test func pillTitleNamesRecentDays() {
        #expect(rules.pillTitle(for: date(25, 9, 0)) == AppString.today)
        #expect(rules.pillTitle(for: date(24, 9, 0)) == AppString.yesterday)
        #expect(rules.pillTitle(for: date(23, 9, 0)) == AppString.dayBeforeYesterday)
        #expect(rules.timeText(for: date(25, 23, 56)) == "23:56")
    }

    @Test func pillTitleShowsDateForOlderDays() {
        let title = rules.pillTitle(for: date(19, 9, 0))

        #expect(title.hasPrefix("19"))
        #expect(!title.contains("2026"))
    }

    @Test func pillTitleShowsYearForPreviousYears() {
        let older = Self.calendar.date(from: DateComponents(year: 2025, month: 3, day: 2, hour: 10)) ?? .distantPast

        #expect(rules.pillTitle(for: older).contains("2025"))
    }

    // MARK: - Подпись трат за месяц

    @Test func spendCaptionUsesPrepositionalMonth() {
        let caption = AppString.spentInMonth(MoneyFormat.money(18_400), month: 11)

        #expect(caption == "18\(nbsp)400\(nbsp)₸ в ноябре")
    }

    // MARK: - Цвет плитки категории

    @Test func legacyCategoryColorsMapToNearestToken() {
        #expect(DS.CategoryColor(legacyHex: "#34C759") == .green)
        #expect(DS.CategoryColor(legacyHex: "#007AFF") == .blue)
        #expect(DS.CategoryColor(legacyHex: "#FF9500") == .orange)
        #expect(DS.CategoryColor(legacyHex: "#AF52DE") == .purple)
        #expect(DS.CategoryColor(legacyHex: "#FF2D55") == .pink)
    }

    @Test func categoryFormSwatchesKeepTheirColorInOtherScreens() {
        for swatch in DS.AccountColor.allCases {
            #expect(DS.CategoryColor(legacyHex: swatch.categoryHex).rawValue == swatch.rawValue)
        }
    }

    @Test func unknownCategoryColorFallsBackToBlue() {
        #expect(DS.CategoryColor(legacyHex: "nonsense") == .blue)
        #expect(DS.CategoryColor(legacyHex: "#808080") == .blue)
    }
}

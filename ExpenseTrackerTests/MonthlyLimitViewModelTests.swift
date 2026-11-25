//
//  MonthlyLimitViewModelTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 26.11.2026.
//

import Foundation
import Testing
@testable import ExpenseTracker

/// Лист «Лимит на месяц»: набор клавиатурой 3×4, пресеты, сумма на день, сохранение и удаление
@MainActor
struct MonthlyLimitViewModelTests {

    // MARK: - Helpers

    private let store = MonthlyLimitStore(defaults: UserDefaults(suiteName: UUID().uuidString) ?? .standard)

    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Almaty") ?? .current
        return calendar
    }()

    /// 20 ноября 2026: в месяце 30 дней
    private func makeViewModel() -> MonthlyLimitViewModel {
        let now = calendar.date(from: DateComponents(year: 2026, month: 11, day: 20, hour: 12)) ?? .now
        return MonthlyLimitViewModel(limitStore: store, now: { now }, calendar: calendar)
    }

    private func type(_ keys: [CalculatorKey], into viewModel: MonthlyLimitViewModel) {
        keys.forEach(viewModel.press)
    }

    // MARK: - Tests

    @Test func emptyWithoutLimit() {
        let viewModel = makeViewModel()

        #expect(viewModel.isEmpty)
        #expect(!viewModel.canSave)
        #expect(viewModel.saveButtonTitle == AppString.enterAmount)
        #expect(viewModel.perDay == nil)
        #expect(!viewModel.hasLimit)
    }

    @Test func startsFromSavedLimit() {
        store.setLimit(250_000)
        let viewModel = makeViewModel()

        #expect(viewModel.amount == 250_000)
        #expect(viewModel.hasLimit)
        #expect(viewModel.isSelected(250_000))
    }

    @Test func perDaySplitsLimitOverDaysOfMonthRoundedDown() {
        let viewModel = makeViewModel()
        viewModel.selectPreset(250_000)

        // 250 000 / 30 = 8 333,3
        #expect(viewModel.perDay == 8_333)
        #expect(viewModel.saveButtonTitle == AppString.save)
    }

    @Test func tripleZeroAndBackspace() {
        let viewModel = makeViewModel()
        type([.digit(2), .digit(5), .tripleZero], into: viewModel)

        #expect(viewModel.amount == 25_000)

        type([.digit(0), .backspace, .backspace], into: viewModel)

        #expect(viewModel.amount == 2_500)
    }

    @Test func leadingZerosAreIgnored() {
        let viewModel = makeViewModel()
        type([.digit(0), .tripleZero, .digit(7)], into: viewModel)

        #expect(viewModel.digits == "7")
    }

    @Test func amountIsCappedAtNineDigits() {
        let viewModel = makeViewModel()
        type([.digit(1), .tripleZero, .tripleZero, .digit(5), .digit(5)], into: viewModel)

        #expect(viewModel.digits == "100000055")

        // «000» целиком не помещается — не набирается совсем, как и лишняя цифра
        type([.tripleZero, .digit(9)], into: viewModel)

        #expect(viewModel.digits == "100000055")
    }

    @Test func calculatorOnlyKeysDoNothing() {
        let viewModel = makeViewModel()
        type([.digit(5), .comma, .operator(.plus), .digit(1)], into: viewModel)

        #expect(viewModel.amount == 51)
    }

    @Test func backspaceToEmptyDisablesSave() {
        let viewModel = makeViewModel()
        type([.digit(5), .backspace, .backspace], into: viewModel)

        #expect(viewModel.isEmpty)
        #expect(!viewModel.canSave)
    }

    @Test func saveAndRemoveUpdateStore() {
        let viewModel = makeViewModel()
        viewModel.selectPreset(300_000)
        viewModel.save()

        #expect(store.limit == 300_000)

        viewModel.removeLimit()

        #expect(store.limit == nil)
    }

    @Test func saveWithoutAmountKeepsLimit() {
        store.setLimit(150_000)
        let viewModel = makeViewModel()
        type(Array(repeating: .backspace, count: 6), into: viewModel)
        viewModel.save()

        #expect(store.limit == 150_000)
    }
}

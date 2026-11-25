//
//  MonthlyLimitViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation

/// Лист «Лимит на месяц»: сумма набирается клавиатурой или пресетом,
/// под ней — сколько выйдет в день при равномерных тратах
@MainActor
@Observable
final class MonthlyLimitViewModel {

    // MARK: - Properties

    private(set) var input: DigitAmountInput

    let presets: [Decimal] = Constants.presets

    private let limitStore: MonthlyLimitStore
    /// Текущий момент и календарь; подменяются в тестах
    private let now: () -> Date
    private let calendar: Calendar

    // MARK: - Init

    init(limitStore: MonthlyLimitStore, now: @escaping () -> Date = { .now }, calendar: Calendar = .current) {
        self.limitStore = limitStore
        self.now = now
        self.calendar = calendar
        self.input = DigitAmountInput(limitStore.limit)
    }

    // MARK: - Computed Properties

    /// Набранные цифры без разделителей
    var digits: String {
        input.digits
    }

    var amount: Decimal {
        input.amount
    }

    /// «0» серым, пока сумма не введена
    var isEmpty: Bool {
        input.isEmpty
    }

    var canSave: Bool {
        !input.isEmpty
    }

    var saveButtonTitle: String {
        canSave ? AppString.save : AppString.enterAmount
    }

    /// Лимит уже задан — лист предлагает его убрать
    var hasLimit: Bool {
        limitStore.limit != nil
    }

    /// Сумма на день при равномерных тратах: лимит на все дни текущего месяца, вниз до тенге.
    /// nil — сумма не введена
    var perDay: Decimal? {
        guard canSave else { return nil }

        let days = calendar.range(of: .day, in: .month, for: now())?.count ?? Constants.fallbackDaysInMonth
        var source = amount / Decimal(days)
        var result = Decimal()
        NSDecimalRound(&result, &source, 0, .down)
        return result
    }

    func isSelected(_ preset: Decimal) -> Bool {
        amount == preset
    }

    // MARK: - Actions

    func press(_ key: CalculatorKey) {
        input.press(key)
    }

    func selectPreset(_ preset: Decimal) {
        input.set(preset)
    }

    func save() {
        guard canSave else { return }
        limitStore.setLimit(amount)
    }

    func removeLimit() {
        limitStore.setLimit(nil)
    }
}

// MARK: - Constants

private extension MonthlyLimitViewModel {

    enum Constants {
        /// Пресеты из `Design/html/MonthlyLimit.html`
        static let presets: [Decimal] = [150_000, 250_000, 300_000]
        static let fallbackDaysInMonth = 30
    }
}

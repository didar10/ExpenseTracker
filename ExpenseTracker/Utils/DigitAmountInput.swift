//
//  DigitAmountInput.swift
//  ExpenseTracker
//
//  Created by Didar on 26.11.2026.
//

import Foundation

/// Целая сумма с клавиатуры 3×4 (`CalculatorKeypad(layout: .amount)`): цифры, «000» и «⌫».
/// Лимит на месяц и бюджет — в тенге без копеек
struct DigitAmountInput: Equatable {

    // MARK: - Properties

    /// Набранные цифры без разделителей; пусто — сумма не введена
    private(set) var digits: String

    // MARK: - Init

    /// nil, ноль или меньше — пустой ввод; копейки отбрасываются
    init(_ value: Decimal? = nil) {
        digits = value.map(Self.digits(of:)) ?? ""
    }

    // MARK: - Computed Properties

    var amount: Decimal {
        Decimal(string: digits) ?? 0
    }

    var isEmpty: Bool {
        amount == 0
    }

    // MARK: - Methods

    mutating func press(_ key: CalculatorKey) {
        switch key {
        case .digit(let digit):
            append(String(digit))
        case .tripleZero:
            append(String(repeating: "0", count: Constants.tripleZeroCount))
        case .backspace:
            if !digits.isEmpty { digits.removeLast() }
        case .comma, .operator:
            // На этой клавиатуре их нет: сумма целая
            break
        }
    }

    mutating func set(_ value: Decimal) {
        digits = Self.digits(of: value)
    }

    // MARK: - Private Methods

    /// Ведущие нули не набираются; «000», который не помещается целиком, не набирается вовсе
    private mutating func append(_ newDigits: String) {
        guard !digits.isEmpty || newDigits.first != "0" else { return }
        guard digits.count + newDigits.count <= Constants.maxDigits else { return }

        digits += newDigits
    }

    private static func digits(of value: Decimal) -> String {
        var source = value
        var result = Decimal()
        NSDecimalRound(&result, &source, 0, .down)
        return result > 0 ? NSDecimalNumber(decimal: result).stringValue : ""
    }
}

// MARK: - Constants

private extension DigitAmountInput {

    enum Constants {
        /// До 999 999 999 ₸: длиннее сумма не помещается в строку
        static let maxDigits = 9
        static let tripleZeroCount = 3
    }
}

//
//  MoneyFormat.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import Foundation

/// Суммы в стиле редизайна: разряды через неразрывный пробел, дробная часть через запятую,
/// минус типографский. Копейки показываются, только если они есть: «4 850», «12,5»
enum MoneyFormat {

    // MARK: - Methods

    /// 4850 → «4 850», -50 → «−50»
    static func number(_ value: Decimal) -> String {
        let rounded = rounded(value)
        let sign = rounded < 0 ? Constants.minus : ""
        let plain = NSDecimalNumber(decimal: abs(rounded)).description(withLocale: Constants.posix)

        let parts = plain.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        let integer = grouped(String(parts.first ?? "0"))

        guard parts.count > 1 else { return sign + integer }
        return sign + integer + Constants.decimalSeparator + parts[1]
    }

    /// 49300 → «49 300 ₸»
    static func money(_ value: Decimal) -> String {
        number(value) + Constants.groupSeparator + AppString.currencySymbol
    }
}

// MARK: - Private Methods

private extension MoneyFormat {

    static func rounded(_ value: Decimal) -> Decimal {
        var input = value
        var output = Decimal()
        NSDecimalRound(&output, &input, Constants.fractionDigits, .plain)
        return output
    }

    static func grouped(_ digits: String) -> String {
        var result = ""
        for (index, character) in digits.enumerated() {
            if index > 0, (digits.count - index) % Constants.groupSize == 0 {
                result.append(Constants.groupSeparator)
            }
            result.append(character)
        }
        return result
    }
}

// MARK: - Constants

private enum Constants {
    static let fractionDigits = 2
    static let groupSize = 3
    static let groupSeparator = AppString.amountGroupingSeparator
    static let decimalSeparator = ","
    static let minus = "−"
    static let posix = Locale(identifier: "en_US_POSIX")
}

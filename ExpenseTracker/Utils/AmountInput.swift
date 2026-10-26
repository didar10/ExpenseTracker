//
//  AmountInput.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation

/// Ввод суммы: хранит набранную строку («1350000.5») и показывает ее
/// с разделителями разрядов («1 350 000.5»). Общий для всех экранов с вводом суммы —
/// и с цифровой клавиатурой NumericKeypadView, и с обычным полем ввода
struct AmountInput: Equatable {

    // MARK: - Properties

    /// Набранная строка без разделителей разрядов; дробная часть — через точку
    private(set) var raw: String

    // MARK: - Init

    init(_ raw: String = "") {
        self.raw = raw
    }

    /// Начальное значение из сохраненной суммы; nil или ноль — пустое поле
    init(_ value: Decimal?) {
        guard let value, value > 0 else {
            self.init()
            return
        }

        self.init(value.description)
    }

    /// Текст из обычного поля ввода, где сумма показана с разделителями разрядов.
    /// Оставляет цифры и одну точку (запятая тоже считается точкой) и обрезает до пределов длины
    init(typedText: String, previous: AmountInput) {
        // Стерт разделитель разрядов: цифры не изменились, а текст стал короче.
        // Без этого разделитель тут же вернулся бы и стирание «не срабатывало»
        let typedDigits = typedText.filter { $0 != Character(AppString.amountGroupingSeparator) }
        if typedDigits == previous.raw, typedText.count < previous.display.count {
            self.init(Self.removingDigit(beforeDeletedSeparatorIn: previous, typedText: typedText))
            return
        }

        self.init(Self.sanitized(typedText))
    }

    // MARK: - Computed Properties

    /// Сумма с разделителями разрядов для отображения: 1350000 → 1 350 000
    var display: String {
        guard !raw.isEmpty else { return "0" }

        let parts = raw.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        let groupedInteger = Self.groupedDigits(String(parts[0]))

        guard parts.count > 1 else { return groupedInteger }

        return groupedInteger + AppString.amountDecimalSeparator + parts[1]
    }

    /// Введена ли сумма — влияет на цвет «0» на экране: набранный ноль не плейсхолдер
    var hasInput: Bool {
        !raw.isEmpty
    }

    var value: Decimal? {
        Decimal(string: raw.replacingOccurrences(of: ",", with: "."))
    }

    var isPositive: Bool {
        guard let value else { return false }
        return value > 0
    }

    // MARK: - Methods

    /// - Returns: false — нажатие отклонено (предел длины, пустое поле)
    @discardableResult
    mutating func apply(_ key: NumericKeypadView.Key) -> Bool {
        switch key {
        case .number(let digit):
            return appendNumber(digit)
        case .decimal:
            return appendDecimal()
        case .delete:
            return deleteLast()
        }
    }

    /// - Returns: false — поле уже пустое
    @discardableResult
    mutating func clear() -> Bool {
        guard !raw.isEmpty else { return false }

        raw = ""
        return true
    }

    // MARK: - Private Methods

    private mutating func appendNumber(_ digit: String) -> Bool {
        guard canAppendDigit else { return false }

        if raw == "0" {
            raw = digit
        } else {
            raw.append(digit)
        }

        return true
    }

    private mutating func appendDecimal() -> Bool {
        guard !raw.contains(AppString.amountDecimalSeparator) else { return false }

        raw = raw.isEmpty ? "0." : raw + AppString.amountDecimalSeparator

        return true
    }

    private mutating func deleteLast() -> Bool {
        guard !raw.isEmpty else { return false }

        raw.removeLast()

        return true
    }

    /// Целая часть ограничена длиной поля, дробная — копейками
    private var canAppendDigit: Bool {
        let parts = raw.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)

        guard parts.count > 1 else {
            return raw.count < Limit.integerDigits
        }

        return parts[1].count < Limit.fractionDigits
    }

    private static func sanitized(_ text: String) -> String {
        var integer = ""
        var fraction = ""
        var hasSeparator = false

        for character in text {
            if character.isNumber, character.isASCII {
                if hasSeparator {
                    fraction.append(character)
                } else {
                    integer.append(character)
                }
            } else if character == "." || character == ",", !hasSeparator {
                hasSeparator = true
            }
        }

        // «007» → «7», но «0» перед точкой остается: «0.5»
        while integer.count > 1, integer.hasPrefix("0") {
            integer.removeFirst()
        }
        if hasSeparator, integer.isEmpty {
            integer = "0"
        }

        integer = String(integer.prefix(Limit.integerDigits))
        fraction = String(fraction.prefix(Limit.fractionDigits))

        return hasSeparator ? integer + AppString.amountDecimalSeparator + fraction : integer
    }

    /// Курсор стоял после разделителя разрядов: стирается цифра перед ним
    private static func removingDigit(beforeDeletedSeparatorIn previous: AmountInput, typedText: String) -> String {
        let oldCharacters = Array(previous.display)
        let newCharacters = Array(typedText)
        let deletedIndex = zip(oldCharacters, newCharacters)
            .enumerated()
            .first { $0.element.0 != $0.element.1 }?
            .offset ?? newCharacters.count

        let separator = Character(AppString.amountGroupingSeparator)
        let digitsBefore = oldCharacters[..<deletedIndex].filter { $0 != separator }.count
        guard digitsBefore > 0 else { return previous.raw }

        var raw = Array(previous.raw)
        raw.remove(at: digitsBefore - 1)
        return String(raw)
    }

    /// Разбивает целую часть суммы на группы по три цифры справа налево
    private static func groupedDigits(_ digits: String) -> String {
        var reversedGrouped = ""

        for (offset, character) in digits.reversed().enumerated() {
            if offset > 0, offset % Limit.groupSize == 0 {
                reversedGrouped.append(AppString.amountGroupingSeparator)
            }
            reversedGrouped.append(character)
        }

        return String(reversedGrouped.reversed())
    }
}

// MARK: - Constants

private extension AmountInput {

    enum Limit {
        static let integerDigits = 12
        static let fractionDigits = 2
        static let groupSize = 3
    }
}

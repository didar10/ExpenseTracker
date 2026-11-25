//
//  CalculatorEngine.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import Foundation

/// Оператор калькулятора
enum CalculatorOperator: CaseIterable {
    case plus
    case minus
    case multiply
    case divide

    // MARK: - Computed Properties

    /// Типографский символ: «−» — минус, а не дефис
    var symbol: String {
        switch self {
        case .plus: return "+"
        case .minus: return "−"
        case .multiply: return "×"
        case .divide: return "÷"
        }
    }

    /// × и ÷ выполняются раньше + и −
    fileprivate var isMultiplicative: Bool {
        self == .multiply || self == .divide
    }
}

/// Клавиша калькулятора
enum CalculatorKey: Hashable {
    case digit(Int)
    case comma
    case `operator`(CalculatorOperator)
    case backspace

    // MARK: - Init

    /// Клавиша по символу: «0»…«9», «,», «+ − × ÷», «⌫»
    init?(_ character: Character) {
        if let value = character.wholeNumberValue, (0...9).contains(value) {
            self = .digit(value)
            return
        }

        switch character {
        case ",": self = .comma
        case "⌫": self = .backspace
        default:
            guard let op = CalculatorOperator.allCases.first(where: { $0.symbol == String(character) }) else {
                return nil
            }
            self = .operator(op)
        }
    }
}

/// Ошибка вычисления; сообщение показывается под суммой
enum CalculatorError: Equatable {
    case divisionByZero
    case nonPositiveResult

    var message: String {
        switch self {
        case .divisionByZero: return AppString.calculatorDivisionByZero
        case .nonPositiveResult: return AppString.calculatorNonPositive
        }
    }
}

/// Калькулятор суммы без UI: ввод по клавишам, выражение с приоритетом × ÷ над + −, Decimal.
///
/// Правила ввода:
/// - в числе не больше 9 цифр до запятой и 2 после; лишние цифры игнорируются;
/// - «0» в начале числа заменяется следующей цифрой; «,» без цифр превращается в «0,»;
/// - оператор в начале игнорируется, второй оператор подряд заменяет первый;
/// - висящий в конце оператор показывается, но в результате не участвует.
///
/// Ошибки: деление на ноль; итог выражения ≤ 0. Ноль без оператора — не ошибка,
/// а еще не введенная сумма: `result == 0`, `isValid == false`
struct CalculatorEngine: Equatable {

    // MARK: - Types

    private enum Token: Equatable {
        /// Число как набрано: «1200», «0,5», «12,» — без разделителей разрядов
        case number(String)
        case `operator`(CalculatorOperator)
    }

    // MARK: - Properties

    private var tokens: [Token] = []

    // MARK: - Computed Properties

    /// Выражение для показа: «1 200 + 800» (разряды — неразрывным пробелом)
    var expressionText: String {
        tokens.map { token in
            switch token {
            case .number(let raw): return Self.formatted(raw)
            case .operator(let op): return op.symbol
            }
        }
        .joined(separator: " ")
    }

    /// Есть ли в выражении оператор — экран показывает строку выражения только тогда
    var hasOperator: Bool {
        tokens.contains { if case .operator = $0 { return true } else { return false } }
    }

    /// Итог, округленный до тиын. nil — ничего не введено или деление на ноль
    var result: Decimal? {
        switch evaluation {
        case .value(let value): return value
        case .empty, .divisionByZero: return nil
        }
    }

    var error: CalculatorError? {
        switch evaluation {
        case .divisionByZero:
            return .divisionByZero
        case .value(let value) where value <= 0 && hasOperator:
            return .nonPositiveResult
        case .value, .empty:
            return nil
        }
    }

    /// Сумму можно сохранять: есть результат, он больше нуля и ошибок нет
    var isValid: Bool {
        guard let result, error == nil else { return false }
        return result > 0
    }

    // MARK: - Init

    init() {}

    /// Сохраненная сумма как уже набранное число — для редактирования операции.
    /// Ноль и отрицательная сумма дают пустой ввод
    init(amount: Decimal) {
        guard amount > 0 else { return }

        let plain = NSDecimalNumber(decimal: Self.rounded(amount)).description(withLocale: Limits.posix)
        let parts = plain.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        let integer = String((parts.first ?? "").suffix(Limits.integerDigits))

        guard parts.count > 1 else {
            tokens = [.number(integer)]
            return
        }
        tokens = [.number(integer + String(Limits.comma) + parts[1].prefix(Limits.fractionDigits))]
    }

    // MARK: - Methods

    mutating func input(_ key: CalculatorKey) {
        switch key {
        case .digit(let digit): inputDigit(digit)
        case .comma: inputComma()
        case .operator(let op): inputOperator(op)
        case .backspace: deleteLast()
        }
    }

    mutating func clear() {
        tokens.removeAll()
    }
}

// MARK: - Input

private extension CalculatorEngine {

    mutating func inputDigit(_ digit: Int) {
        guard case .number(var raw) = tokens.last else {
            tokens.append(.number(String(digit)))
            return
        }

        if raw == "0" {
            raw = String(digit)
        } else if let commaIndex = raw.firstIndex(of: Limits.comma) {
            guard raw[raw.index(after: commaIndex)...].count < Limits.fractionDigits else { return }
            raw.append(String(digit))
        } else {
            guard raw.count < Limits.integerDigits else { return }
            raw.append(String(digit))
        }

        tokens[tokens.count - 1] = .number(raw)
    }

    mutating func inputComma() {
        guard case .number(let raw) = tokens.last else {
            tokens.append(.number("0\(Limits.comma)"))
            return
        }
        guard !raw.contains(Limits.comma) else { return }

        tokens[tokens.count - 1] = .number(raw + String(Limits.comma))
    }

    mutating func inputOperator(_ op: CalculatorOperator) {
        switch tokens.last {
        case .none:
            return
        case .operator:
            tokens[tokens.count - 1] = .operator(op)
        case .number(let raw):
            // «12,» перед оператором становится «12»
            if raw.last == Limits.comma {
                tokens[tokens.count - 1] = .number(String(raw.dropLast()))
            }
            tokens.append(.operator(op))
        }
    }

    mutating func deleteLast() {
        guard let last = tokens.last else { return }

        switch last {
        case .operator:
            tokens.removeLast()
        case .number(let raw):
            let shortened = String(raw.dropLast())
            if shortened.isEmpty {
                tokens.removeLast()
            } else {
                tokens[tokens.count - 1] = .number(shortened)
            }
        }
    }
}

// MARK: - Evaluation

private extension CalculatorEngine {

    enum Evaluation {
        case empty
        case value(Decimal)
        case divisionByZero
    }

    var evaluation: Evaluation {
        var items = tokens
        // Висящий оператор не участвует в вычислении
        if case .operator = items.last {
            items.removeLast()
        }
        guard !items.isEmpty else { return .empty }

        // Первый проход — × и ÷, второй — + и −, оба слева направо
        var terms: [Decimal] = []
        var additive: [CalculatorOperator] = []
        var current: Decimal?
        var pending: CalculatorOperator?

        for item in items {
            switch item {
            case .operator(let op):
                pending = op
            case .number(let raw):
                let number = Self.decimal(raw)
                guard let left = current, let op = pending else {
                    current = number
                    continue
                }

                if op.isMultiplicative {
                    if op == .divide {
                        guard number != 0 else { return .divisionByZero }
                        current = left / number
                    } else {
                        current = left * number
                    }
                } else {
                    terms.append(left)
                    additive.append(op)
                    current = number
                }
                pending = nil
            }
        }

        guard var total = terms.first ?? current else { return .empty }
        if let current, !terms.isEmpty { terms.append(current) }

        for (index, op) in additive.enumerated() {
            let right = terms[index + 1]
            total = op == .plus ? total + right : total - right
        }

        return .value(Self.rounded(total))
    }

    static func decimal(_ raw: String) -> Decimal {
        let normalized = raw.replacingOccurrences(of: String(Limits.comma), with: ".")
        return Decimal(string: normalized, locale: Limits.posix) ?? 0
    }

    static func rounded(_ value: Decimal) -> Decimal {
        var input = value
        var output = Decimal()
        NSDecimalRound(&output, &input, Limits.fractionDigits, .plain)
        return output
    }

    /// «1234567,5» → «1 234 567,5»
    static func formatted(_ raw: String) -> String {
        let parts = raw.split(separator: Limits.comma, maxSplits: 1, omittingEmptySubsequences: false)
        let integer = String(parts.first ?? "")

        var grouped = ""
        for (index, character) in integer.enumerated() {
            if index > 0, (integer.count - index) % Limits.groupSize == 0 {
                grouped.append(Limits.groupSeparator)
            }
            grouped.append(character)
        }

        guard parts.count > 1 else { return grouped }
        return grouped + String(Limits.comma) + parts[1]
    }
}

// MARK: - Limits

private enum Limits {
    static let integerDigits = 9
    static let fractionDigits = 2
    static let groupSize = 3
    static let comma: Character = ","
    static let groupSeparator: Character = "\u{00A0}"
    static let posix = Locale(identifier: "en_US_POSIX")
}

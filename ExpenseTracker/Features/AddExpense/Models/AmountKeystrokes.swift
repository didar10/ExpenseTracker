//
//  AmountKeystrokes.swift
//  ExpenseTracker
//
//  Created by Didar on 26.11.2026.
//

/// Счетчики нажатий, изменивших сумму: триггеры «печати» в `AmountHeaderView`.
/// Нажатие, которое ничего не изменило (⌫ на пустой сумме, лишняя запятая), не анимируется
struct AmountKeystrokes: Equatable {

    /// Новый символ в конце крупной суммы — пока в выражении нет оператора
    private(set) var amountPrint = 0
    /// Новый символ в конце строки выражения: оператор или цифра после него
    private(set) var expressionPrint = 0
    /// ⌫ — сумма вздрагивает влево
    private(set) var erase = 0

    mutating func record(_ key: CalculatorKey, hasOperator: Bool) {
        if key == .backspace {
            erase += 1
        } else if hasOperator {
            expressionPrint += 1
        } else {
            amountPrint += 1
        }
    }
}

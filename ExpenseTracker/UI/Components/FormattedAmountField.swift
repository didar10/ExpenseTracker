//
//  FormattedAmountField.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import SwiftUI
import UIKit

/// Поле ввода суммы, которое разбивает ее на разряды прямо при наборе: 500000 → 500 000.
///
/// Исключение из правила «только SwiftUI»: SwiftUI TextField применяет переформатированный
/// текст с задержкой, и при быстром наборе следующая цифра попадала в старый текст
/// («50 0000»). UITextField форматирует каждое нажатие до вставки символа и держит курсор на месте
struct FormattedAmountField: UIViewRepresentable {

    // MARK: - Properties

    let amount: AmountInput
    let placeholder: String
    var style: AppFont = .title
    var accessibilityIdentifier: String?
    /// Поле получает фокус сразу при появлении — клавиатура открывается вместе с экраном
    var isInitiallyFocused = false
    let onChange: (AmountInput) -> Void

    // MARK: - UIViewRepresentable

    func makeCoordinator() -> Coordinator {
        Coordinator(amount: amount, onChange: onChange)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.keyboardType = .decimalPad
        textField.font = style.uiFont
        textField.adjustsFontForContentSizeCategory = true
        textField.textColor = UIColor(AppColor.textPrimary)
        textField.placeholder = placeholder
        textField.text = Self.text(for: amount)
        textField.accessibilityIdentifier = accessibilityIdentifier
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        if isInitiallyFocused {
            DispatchQueue.main.async { textField.becomeFirstResponder() }
        }

        return textField
    }

    func updateUIView(_ textField: UITextField, context: Context) {
        context.coordinator.onChange = onChange

        // Сумма поменялась снаружи — показываем ее; свой ввод поле уже отформатировало
        guard context.coordinator.amount != amount else { return }

        context.coordinator.amount = amount
        textField.text = Self.text(for: amount)
    }

    // MARK: - Private Methods

    /// Пока сумма не введена, поле пустое — виден плейсхолдер
    fileprivate static func text(for amount: AmountInput) -> String {
        amount.hasInput ? amount.display : ""
    }
}

// MARK: - Coordinator

extension FormattedAmountField {

    final class Coordinator: NSObject, UITextFieldDelegate {

        // MARK: - Properties

        var amount: AmountInput
        var onChange: (AmountInput) -> Void

        private let groupingSeparator = Character(AppString.amountGroupingSeparator)

        // MARK: - Init

        init(amount: AmountInput, onChange: @escaping (AmountInput) -> Void) {
            self.amount = amount
            self.onChange = onChange
        }

        // MARK: - UITextFieldDelegate

        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            let currentText = textField.text ?? ""
            var editRange = range

            // Стирание разделителя разрядов стирает цифру перед ним:
            // иначе разделитель вернулся бы на место и ⌫ «не срабатывал»
            if string.isEmpty, range.length == 1, range.location > 0,
               let deleted = Range(range, in: currentText),
               currentText[deleted].first == groupingSeparator {
                editRange = NSRange(location: range.location - 1, length: 1)
            }

            guard let swiftRange = Range(editRange, in: currentText) else { return false }

            let editedText = currentText.replacingCharacters(in: swiftRange, with: string)
            let newAmount = AmountInput(typedText: editedText, previous: amount)
            let newText = FormattedAmountField.text(for: newAmount)

            // Курсор остается после того же числа значащих символов, что и в набранном тексте
            let cursorInEdited = editedText.utf16.index(
                editedText.utf16.startIndex,
                offsetBy: editRange.location + (string as NSString).length
            )
            let significantBeforeCursor = editedText.utf16[..<cursorInEdited]
                .filter { $0 != groupingSeparator.utf16.first }
                .count

            textField.text = newText
            moveCursor(in: textField, afterSignificantCharacters: significantBeforeCursor, of: newText)

            if newAmount != amount {
                amount = newAmount
                onChange(newAmount)
            }

            return false
        }

        // MARK: - Private Methods

        private func moveCursor(in textField: UITextField, afterSignificantCharacters count: Int, of text: String) {
            var remaining = count
            var offset = 0

            for unit in text.utf16 {
                guard remaining > 0 else { break }
                if unit != groupingSeparator.utf16.first {
                    remaining -= 1
                }
                offset += 1
            }

            guard let position = textField.position(from: textField.beginningOfDocument, offset: offset) else { return }
            textField.selectedTextRange = textField.textRange(from: position, to: position)
        }
    }
}

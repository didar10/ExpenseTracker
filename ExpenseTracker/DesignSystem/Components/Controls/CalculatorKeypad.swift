//
//  CalculatorKeypad.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Клавиатура калькулятора 4×4: цифры, «,», «⌫» и операторы.
/// Операторы — черные, «,» и «⌫» — на фоне bg; нажатие — `OutlineClickStyle`.
/// Клавиши 50 pt, при нехватке места — до 40 pt
struct CalculatorKeypad: View {

    // MARK: - Properties

    let onKey: (CalculatorKey) -> Void

    private static let rows: [[CalculatorKey]] = [
        [.digit(1), .digit(2), .digit(3), .operator(.plus)],
        [.digit(4), .digit(5), .digit(6), .operator(.minus)],
        [.digit(7), .digit(8), .digit(9), .operator(.multiply)],
        [.comma, .digit(0), .backspace, .operator(.divide)]
    ]

    // MARK: - Body

    var body: some View {
        Grid(horizontalSpacing: DS.Spacing.sm, verticalSpacing: DS.Spacing.sm) {
            ForEach(Self.rows.indices, id: \.self) { row in
                GridRow {
                    ForEach(Self.rows[row], id: \.self) { key in
                        keyButton(key)
                    }
                }
            }
        }
    }
}

// MARK: - Subviews

private extension CalculatorKeypad {

    func keyButton(_ key: CalculatorKey) -> some View {
        let style = KeyAppearance(key)

        return Button {
            onKey(key)
        } label: {
            label(for: key)
                .font(style.font)
                // На низком экране (iPhone SE) клавиши ужимаются, чтобы экран обошелся без прокрутки
                .frame(maxWidth: .infinity, minHeight: Metrics.minimumKeyHeight, maxHeight: Metrics.keyHeight)
        }
        .buttonStyle(OutlineClickStyle(
            shape: .bordered(radius: DS.Radius.control),
            fill: style.fill,
            foreground: style.foreground
        ))
        .accessibilityLabel(style.accessibilityLabel)
    }

    @ViewBuilder
    func label(for key: CalculatorKey) -> some View {
        switch key {
        case .digit(let digit): Text(String(digit))
        case .comma: Text(verbatim: ",")
        case .operator(let op): Text(op.symbol)
        case .backspace:
            DS.Icon.backspace
                .font(.system(size: DS.Size.iconXL, weight: .semibold))
        }
    }
}

// MARK: - Key Appearance

private struct KeyAppearance {

    let fill: Color
    let foreground: Color
    let font: Font
    let accessibilityLabel: String

    init(_ key: CalculatorKey) {
        switch key {
        case .digit(let digit):
            fill = DS.Color.surface
            foreground = DS.Color.ink
            font = DS.Font.key
            accessibilityLabel = String(digit)
        case .comma:
            fill = DS.Color.bg
            foreground = DS.Color.ink
            font = DS.Font.key
            accessibilityLabel = AppString.calculatorKeyComma
        case .backspace:
            fill = DS.Color.bg
            foreground = DS.Color.ink
            font = DS.Font.key
            accessibilityLabel = AppString.calculatorKeyBackspace
        case .operator(let op):
            fill = DS.Color.ink
            foreground = DS.Color.bg
            font = DS.Font.keyOperator
            accessibilityLabel = Self.label(for: op)
        }
    }

    private static func label(for op: CalculatorOperator) -> String {
        switch op {
        case .plus: return AppString.calculatorKeyPlus
        case .minus: return AppString.calculatorKeyMinus
        case .multiply: return AppString.calculatorKeyMultiply
        case .divide: return AppString.calculatorKeyDivide
        }
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/AddTransaction.html` (.keys, .key)
    static let keyHeight: CGFloat = 50
    static let minimumKeyHeight: CGFloat = 40
}

// MARK: - Previews

#if DEBUG
private struct CalculatorKeypadPreview: View {

    @State private var engine = CalculatorEngine()

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Выражение · результат · ошибка") {
                VStack(spacing: DS.Spacing.xs) {
                    Text(engine.expressionText.isEmpty ? " " : engine.expressionText)
                        .font(DS.Font.expression)
                        .foregroundStyle(DS.Color.ink2)
                    Text(engine.result.map { "\($0)" } ?? "—")
                        .font(DS.Font.amountXL)
                        .foregroundStyle(DS.Color.ink)
                    Text(engine.error?.message ?? " ")
                        .font(DS.Font.caption)
                        .foregroundStyle(DS.Color.danger)
                }
                .frame(maxWidth: .infinity)
            }
            CalculatorKeypad { engine.input($0) }
            DSPreviewCase("Нажатые клавиши: цифра и оператор") {
                HStack(spacing: DS.Spacing.sm) {
                    OutlineClickBody(shape: .bordered(radius: DS.Radius.control), fill: DS.Color.surface, isPressed: true) {
                        Text("7").font(DS.Font.key).frame(maxWidth: .infinity, minHeight: 50)
                    }
                    OutlineClickBody(shape: .bordered(radius: DS.Radius.control), fill: DS.Color.ink, foreground: DS.Color.bg, isPressed: true) {
                        Text("×").font(DS.Font.keyOperator).frame(maxWidth: .infinity, minHeight: 50)
                    }
                }
            }
        }
    }
}

#Preview("Светлая") {
    CalculatorKeypadPreview()
}

#Preview("Темная") {
    CalculatorKeypadPreview()
        .preferredColorScheme(.dark)
}
#endif

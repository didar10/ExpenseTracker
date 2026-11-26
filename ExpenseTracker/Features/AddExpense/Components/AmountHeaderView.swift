//
//  AmountHeaderView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Сумма операции: строка выражения серым, крупная сумма с ₸ и строка ошибки.
/// Высота постоянная — появление выражения или ошибки не сдвигает экран.
///
/// «Печать суммы»: новая цифра падает сверху (−12 → +2 → 0 pt, масштаб 1.25 → 1, ~160 мс),
/// в строке выражения так же появляется оператор; ⌫ — резкий сдвиг суммы влево на 4 pt.
/// После цифр мигает блочный курсор. При «Уменьшить движение» символ только проявляется,
/// а ⌫ коротко приглушает сумму — без сдвигов и масштаба
struct AmountHeaderView: View {

    // MARK: - Properties

    /// «1 200 + 800»; nil — выражения нет, строка остается пустой
    let expression: String?
    /// «4 850», «0», «—»
    let amount: String
    /// Ноль еще не введенной суммы — серым
    let isPlaceholder: Bool
    let errorMessage: String?
    /// Низкий экран: сумма шрифтом amountL и без зазора над выражением
    var isCompact = false
    /// Триггеры анимаций; по умолчанию — без анимаций (превью)
    var keystrokes = AmountKeystrokes()

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ScaledMetric(relativeTo: .largeTitle) private var regularFontSize = DS.Font.Size.amountXL
    @ScaledMetric(relativeTo: .largeTitle) private var compactFontSize = DS.Font.Size.amountL

    /// Ширина суммы без ужатия и доступная ширина: сумма из нескольких Text
    /// не умеет `minimumScaleFactor` целиком, поэтому ужимается масштабом
    @State private var naturalWidth: CGFloat = .zero
    @State private var availableWidth: CGFloat = .zero
    @State private var isCursorVisible = true

    // MARK: - Computed Properties

    private var fontSize: CGFloat {
        isCompact ? compactFontSize : regularFontSize
    }

    private var fitScale: CGFloat {
        guard naturalWidth > .zero, availableWidth > .zero else { return 1 }
        return min(1, max(Metrics.minimumScale, availableWidth / naturalWidth))
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            expressionLine
                .frame(minHeight: Metrics.expressionHeight)
                .padding(.top, isCompact ? .zero : DS.Spacing.sm)
                .accessibilityHidden(expression == nil)

            amountLine
                .frame(maxWidth: .infinity, minHeight: isCompact ? Metrics.compactAmountHeight : Metrics.amountHeight)
                .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { availableWidth = $0 }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(AppString.accessibilityAmount)
                .accessibilityValue("\(amount) \(AppString.currencySymbol)")

            Text(errorMessage ?? " ")
                .font(DS.Font.label)
                .foregroundStyle(DS.Color.danger)
                .lineLimit(1)
                .frame(minHeight: Metrics.errorHeight)
                .accessibilityHidden(errorMessage == nil)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        // Пока набирают, курсор горит; мигание возобновляется после паузы
        .task(id: keystrokes) { await blinkCursor() }
    }
}

// MARK: - Subviews

private extension AmountHeaderView {

    @ViewBuilder
    var expressionLine: some View {
        if let expression {
            let parts = PrintedParts(expression)

            HStack(spacing: .zero) {
                Text(parts.head)
                    .truncationMode(.head)
                PrintedCharacter(text: parts.last, trigger: keystrokes.expressionPrint)
            }
            .font(DS.Font.expression)
            .foregroundStyle(DS.Color.ink2)
            .lineLimit(1)
        } else {
            Text(verbatim: " ")
                .font(DS.Font.expression)
        }
    }

    /// Сумма, курсор и ₸ одной строкой: ужимаются вместе
    var amountLine: some View {
        let parts = PrintedParts(amount)

        return HStack(alignment: .firstTextBaseline, spacing: .zero) {
            Group {
                Text(parts.head)
                PrintedCharacter(text: parts.last, trigger: keystrokes.amountPrint)
            }
            .font(isCompact ? DS.Font.amountL : DS.Font.amountXL)
            .foregroundStyle(isPlaceholder ? DS.Color.ink2 : DS.Color.ink)

            cursor
                .padding(.leading, Metrics.cursorGap)

            Text(AppString.currencySymbol)
                .font(isCompact ? DS.Font.amountLSign : DS.Font.amountXLSign)
                .foregroundStyle(DS.Color.ink2)
                .padding(.leading, Metrics.signSpacing)
        }
        .lineLimit(1)
        .fixedSize()
        .keyframeAnimator(initialValue: EraseFrame(), trigger: keystrokes.erase) { content, frame in
            content
                .offset(x: reduceMotion ? .zero : frame.offset)
                .opacity(reduceMotion ? frame.reducedOpacity : 1)
        } keyframes: { _ in
            KeyframeTrack(\.offset) {
                LinearKeyframe(DS.Motion.Erase.offset, duration: DS.Motion.Erase.outDuration)
                LinearKeyframe(.zero, duration: DS.Motion.Erase.backDuration)
            }
            KeyframeTrack(\.reducedOpacity) {
                LinearKeyframe(DS.Motion.Erase.reducedOpacity, duration: DS.Motion.Erase.outDuration)
                LinearKeyframe(1, duration: DS.Motion.Erase.backDuration)
            }
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { naturalWidth = $0 }
        .scaleEffect(fitScale)
    }

    /// Блочный курсор █ высотой с цифру, нижним краем на базовой линии
    var cursor: some View {
        Rectangle()
            .fill(DS.Color.ink)
            .frame(width: fontSize * Metrics.cursorWidthRatio, height: fontSize * Metrics.cursorHeightRatio)
            .alignmentGuide(.firstTextBaseline) { $0[.bottom] }
            .opacity(isCursorVisible ? 1 : .zero)
            .accessibilityHidden(true)
    }
}

// MARK: - Private Methods

private extension AmountHeaderView {

    /// Шаг 1 с: полсекунды виден, полсекунды скрыт. Без плавности — как у терминала
    func blinkCursor() async {
        isCursorVisible = true

        while !Task.isCancelled {
            try? await Task.sleep(for: DS.Motion.cursorBlink)
            guard !Task.isCancelled else { return }
            isCursorVisible.toggle()
        }
    }
}

// MARK: - Printed Parts

/// Строка без последнего символа и сам символ: «печатается» только он,
/// остальное перестраивается без анимации
private struct PrintedParts {
    let head: String
    let last: String

    init(_ text: String) {
        head = String(text.dropLast())
        last = text.last.map(String.init) ?? ""
    }
}

// MARK: - Printed Character

/// Символ, который появляется «печатью» при каждой смене `trigger`
private struct PrintedCharacter: View {

    // MARK: - Types

    struct Frame {
        var offset: CGFloat = .zero
        var scale: CGFloat = 1
        var reducedOpacity: Double = 1
    }

    // MARK: - Properties

    let text: String
    let trigger: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Body

    var body: some View {
        Text(text)
            .keyframeAnimator(initialValue: Frame(), trigger: trigger) { content, frame in
                content
                    .scaleEffect(reduceMotion ? 1 : frame.scale, anchor: .bottom)
                    .offset(y: reduceMotion ? .zero : frame.offset)
                    .opacity(reduceMotion ? frame.reducedOpacity : 1)
            } keyframes: { _ in
                let print = DS.Motion.Print.self
                let fall = print.duration * print.overshootShare

                KeyframeTrack(\.offset) {
                    MoveKeyframe(print.startOffset)
                    CubicKeyframe(print.overshoot, duration: fall)
                    CubicKeyframe(.zero, duration: print.duration - fall)
                }
                KeyframeTrack(\.scale) {
                    MoveKeyframe(print.startScale)
                    CubicKeyframe(1, duration: print.duration)
                }
                KeyframeTrack(\.reducedOpacity) {
                    MoveKeyframe(print.reducedStartOpacity)
                    LinearKeyframe(1, duration: print.duration)
                }
            }
    }
}

// MARK: - Erase Frame

private struct EraseFrame {
    var offset: CGFloat = .zero
    var reducedOpacity: Double = 1
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/AddTransaction.html` (.expr, .amt, .err)
    static let expressionHeight: CGFloat = 22
    static let amountHeight: CGFloat = 56
    static let compactAmountHeight: CGFloat = 48
    static let errorHeight: CGFloat = 16
    static let minimumScale: CGFloat = 0.6
    /// ₸ после суммы — `.amt span` (margin-left 8)
    static let signSpacing: CGFloat = 8
    static let cursorGap: CGFloat = 4
    /// Курсор в долях кегля: по ширине — узкая цифра, по высоте — высота цифр Unbounded
    static let cursorWidthRatio: CGFloat = 0.4
    static let cursorHeightRatio: CGFloat = 0.72
}

// MARK: - Previews

#if DEBUG
private struct AmountHeaderGallery: View {

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Пусто") {
                AmountHeaderView(expression: nil, amount: "0", isPlaceholder: true, errorMessage: nil)
            }
            DSPreviewCase("Сумма") {
                AmountHeaderView(expression: nil, amount: "4 850", isPlaceholder: false, errorMessage: nil)
            }
            DSPreviewCase("Выражение") {
                AmountHeaderView(expression: "1 200 + 800", amount: "2 000", isPlaceholder: false, errorMessage: nil)
            }
            DSPreviewCase("Ошибка") {
                AmountHeaderView(expression: "100 ÷ 0", amount: "—", isPlaceholder: false, errorMessage: AppString.calculatorDivisionByZero)
            }
            DSPreviewCase("Компактная (iPhone SE)") {
                AmountHeaderView(expression: "1 200 + 800", amount: "2 000", isPlaceholder: false, errorMessage: nil, isCompact: true)
            }
            DSPreviewCase("Длинная сумма уменьшается") {
                AmountHeaderView(expression: "999 999 999 × 9", amount: "8 999 999 991", isPlaceholder: false, errorMessage: nil)
            }
        }
    }
}

/// Живой набор: клавиатура под суммой, чтобы увидеть печать, ⌫ и курсор
private struct AmountTypingPreview: View {

    @State private var calculator = CalculatorEngine()
    @State private var keystrokes = AmountKeystrokes()

    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            AmountHeaderView(
                expression: calculator.hasOperator ? calculator.expressionText : nil,
                amount: calculator.hasOperator
                    ? calculator.result.map(MoneyFormat.number) ?? "0"
                    : (calculator.expressionText.isEmpty ? "0" : calculator.expressionText),
                isPlaceholder: (calculator.result ?? .zero) == .zero,
                errorMessage: calculator.error?.message,
                keystrokes: keystrokes
            )

            CalculatorKeypad { key in
                let previous = calculator
                calculator.input(key)
                if calculator != previous {
                    keystrokes.record(key, hasOperator: calculator.hasOperator)
                }
            }
        }
        .padding(DS.Spacing.xl)
        .background(DS.Color.bg)
    }
}

#Preview("Светлая") {
    AmountHeaderGallery()
}

#Preview("Темная") {
    AmountHeaderGallery()
        .preferredColorScheme(.dark)
}

#Preview("Набор · светлая") {
    AmountTypingPreview()
}

#Preview("Набор · темная") {
    AmountTypingPreview()
        .preferredColorScheme(.dark)
}
#endif

//
//  AmountHeaderView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Сумма операции: строка выражения серым, крупная сумма с ₸ и строка ошибки.
/// Высота постоянная — появление выражения или ошибки не сдвигает экран
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

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            Text(expression ?? " ")
                .font(DS.Font.expression)
                .foregroundStyle(DS.Color.ink2)
                .lineLimit(1)
                .truncationMode(.head)
                .frame(minHeight: Metrics.expressionHeight)
                .padding(.top, isCompact ? .zero : DS.Spacing.sm)
                .accessibilityHidden(expression == nil)

            amountText
                .lineLimit(1)
                .minimumScaleFactor(Metrics.minimumScale)
                .frame(minHeight: isCompact ? Metrics.compactAmountHeight : Metrics.amountHeight)
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
    }
}

// MARK: - Subviews

private extension AmountHeaderView {

    /// Сумма и ₸ одной строкой, чтобы уменьшались вместе
    var amountText: Text {
        let number = Text(amount)
            .font(isCompact ? DS.Font.amountL : DS.Font.amountXL)
            .foregroundStyle(isPlaceholder ? DS.Color.ink2 : DS.Color.ink)
        let sign = Text(AppString.currencySymbol)
            .font(isCompact ? DS.Font.amountLSign : DS.Font.amountXLSign)
            .foregroundStyle(DS.Color.ink2)

        return Text("\(number)\(AppString.amountGroupingSeparator)\(sign)")
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/AddTransaction.html` (.expr, .amt, .err)
    static let expressionHeight: CGFloat = 22
    static let amountHeight: CGFloat = 56
    static let compactAmountHeight: CGFloat = 48
    static let errorHeight: CGFloat = 16
    static let minimumScale: CGFloat = 0.6
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

#Preview("Светлая") {
    AmountHeaderGallery()
}

#Preview("Темная") {
    AmountHeaderGallery()
        .preferredColorScheme(.dark)
}
#endif

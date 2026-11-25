//
//  BrutalTextField.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Поле формы: метка слева, значение справа. В фокусе обводка утолщается,
/// при ошибке становится красной и под полем появляется сообщение
struct BrutalTextField: View {

    // MARK: - Types

    enum Kind {
        /// Обычный текст — SF 16
        case text
        /// Сумма — JetBrains Mono Bold 16, цифровая клавиатура, суффикс ₸
        case amount
    }

    // MARK: - Properties

    let label: String
    @Binding var text: String
    var placeholder = ""
    var kind: Kind = .text
    /// nil — ошибки нет
    var errorMessage: String?
    var onFocusChange: (Bool) -> Void = { _ in }

    @FocusState private var isFocused: Bool

    // MARK: - Init

    init(
        _ label: String,
        text: Binding<String>,
        placeholder: String = "",
        kind: Kind = .text,
        errorMessage: String? = nil,
        onFocusChange: @escaping (Bool) -> Void = { _ in }
    ) {
        self.label = label
        self._text = text
        self.placeholder = placeholder
        self.kind = kind
        self.errorMessage = errorMessage
        self.onFocusChange = onFocusChange
    }

    // MARK: - Computed Properties

    private var hasError: Bool {
        errorMessage != nil
    }

    private var borderColor: Color {
        hasError ? DS.Color.danger : DS.Color.ink
    }

    private var borderWidth: CGFloat {
        isFocused || hasError ? DS.Stroke.pressed : DS.Stroke.regular
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            field

            if let errorMessage {
                Text(errorMessage)
                    .font(DS.Font.caption)
                    .foregroundStyle(DS.Color.danger)
                    .padding(.horizontal, DS.Spacing.xs)
            }
        }
        .onChange(of: isFocused) { _, focused in onFocusChange(focused) }
    }
}

// MARK: - Subviews

private extension BrutalTextField {

    var field: some View {
        HStack(spacing: Metrics.spacing) {
            Text(label)
                .dsLabel()
                .accessibilityHidden(true)

            input
        }
        .padding(.horizontal, Metrics.horizontalPadding)
        .frame(minHeight: DS.Size.field)
        .background(DS.Color.surface, in: RoundedRectangle(cornerRadius: DS.Radius.control))
        .brutalBorder(radius: DS.Radius.control, lineWidth: borderWidth, color: borderColor)
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
    }

    @ViewBuilder
    var input: some View {
        let prompt = Text(placeholder).foregroundStyle(DS.Color.ink2)

        switch kind {
        case .text:
            TextField(label, text: $text, prompt: prompt)
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.ink)
                .multilineTextAlignment(.trailing)
                .focused($isFocused)
                .accessibilityLabel(label)

        case .amount:
            HStack(spacing: DS.Spacing.xs) {
                TextField(label, text: $text, prompt: prompt)
                    .font(DS.Font.moneyField)
                    .foregroundStyle(DS.Color.ink)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .accessibilityLabel(label)

                Text(AppString.dsCurrencySign)
                    .font(DS.Font.moneyField)
                    .foregroundStyle(DS.Color.ink)
                    .accessibilityHidden(true)
            }
        }
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/Main.html` (.field)
    static let spacing: CGFloat = 10
    static let horizontalPadding: CGFloat = 14
}

// MARK: - Previews

#if DEBUG
private struct BrutalTextFieldGallery: View {

    @State private var name = ""
    @State private var filledName = "Kaspi Gold"
    @State private var balance = "0"

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Пусто · плейсхолдер") {
                BrutalTextField("Название", text: $name, placeholder: "Например, Kaspi Gold")
            }
            DSPreviewCase("Заполнено") {
                BrutalTextField("Название", text: $filledName)
            }
            DSPreviewCase("Сумма") {
                BrutalTextField("Начальный баланс", text: $balance, kind: .amount)
            }
            DSPreviewCase("Ошибка") {
                BrutalTextField("Название", text: $name, placeholder: "Например, Kaspi Gold",
                                errorMessage: "Введите название счёта")
            }
            DSPreviewCase("Disabled") {
                BrutalTextField("Название", text: $filledName)
                    .disabled(true)
            }
        }
    }
}

#Preview("Светлая") {
    BrutalTextFieldGallery()
}

#Preview("Темная") {
    BrutalTextFieldGallery()
        .preferredColorScheme(.dark)
}
#endif

//
//  TransactionRowModel.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Что показывает строка операции в ленте главной: категория, заметка, сумма со знаком
struct TransactionRowModel {

    // MARK: - Properties

    let title: String
    /// Заметка; nil — строка без подписи
    let subtitle: String?
    /// «−2 100», «+480 000»
    let amount: String
    let isIncome: Bool
    let icon: Image
    let color: DS.CategoryColor

    // MARK: - Init

    init(_ transaction: Transaction) {
        let isIncome = transaction.type == .income
        let category = transaction.category

        self.isIncome = isIncome
        // Доход подписывается типом, расход — категорией, как в макете `Main.html`
        title = isIncome ? AppString.income : category?.name ?? AppString.noCategory
        subtitle = transaction.note.flatMap { $0.isEmpty ? nil : $0 }
        amount = MoneyFormat.signed(isIncome ? transaction.amount : -transaction.amount)
        icon = category.map { Image(systemName: $0.icon) }
            ?? (isIncome ? AppImage.incomeFallback : DS.Icon.noCategory)
        color = category.map { DS.CategoryColor(legacyHex: $0.colorHex) } ?? (isIncome ? .green : .blue)
    }

    // MARK: - Computed Properties

    /// VoiceOver читает строку целиком: категория, сумма с валютой и заметка
    var accessibilityLabel: String {
        [title, "\(amount) \(AppString.currencySymbol)", subtitle]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}

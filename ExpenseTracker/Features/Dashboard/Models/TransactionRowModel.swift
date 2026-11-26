//
//  TransactionRowModel.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Что показывает строка операции в ленте главной: категория, заметка, сумма со знаком.
/// Перевод — серая плитка ⇄, «Перевод», «Kaspi Gold → Наличные» и серая сумма
struct TransactionRowModel {

    // MARK: - Properties

    let title: String
    /// Заметка или маршрут перевода; nil — строка без подписи
    let subtitle: String?
    /// «−2 100», «+480 000»; у перевода во «Всех счетах» — без знака: «50 000»
    let amount: String
    let tone: TransactionRow.Tone
    let icon: Image
    let color: DS.CategoryColor

    var isIncome: Bool {
        tone == .income
    }

    // MARK: - Init

    /// - Parameter account: счет фильтра ленты. Перевод для него — списание или зачисление,
    ///   поэтому сумма получает знак; nil — «Все счета», сумма без знака
    init(_ transaction: Transaction, account: Account? = nil) {
        if transaction.kind == .transfer {
            self.init(transfer: transaction, account: account)
        } else {
            self.init(entry: transaction)
        }
    }

    private init(entry transaction: Transaction) {
        let isIncome = transaction.type == .income
        let category = transaction.category

        tone = isIncome ? .income : .expense
        // Доход подписывается типом, расход — категорией, как в макете `Main.html`
        title = isIncome ? AppString.income : category?.name ?? AppString.noCategory
        subtitle = transaction.note.flatMap { $0.isEmpty ? nil : $0 }
        amount = MoneyFormat.signed(isIncome ? transaction.amount : -transaction.amount)
        icon = category.map { Image(systemName: $0.icon) }
            ?? (isIncome ? AppImage.incomeFallback : DS.Icon.noCategory)
        color = category.map { DS.CategoryColor(legacyHex: $0.colorHex) } ?? (isIncome ? .green : .blue)
    }

    private init(transfer: Transaction, account: Account?) {
        tone = .transfer
        title = AppString.transfer
        subtitle = Self.route(of: transfer)
        icon = DS.Icon.transfer
        // Плитку перевода красит `TransactionRow.Tone.transfer`
        color = .blue

        if let account {
            let isOutgoing = transfer.fromAccount?.persistentModelID == account.persistentModelID
            amount = MoneyFormat.signed(isOutgoing ? -transfer.amount : transfer.amount)
        } else {
            amount = MoneyFormat.number(transfer.amount)
        }
    }

    // MARK: - Computed Properties

    /// VoiceOver читает строку целиком: категория, сумма с валютой и заметка
    var accessibilityLabel: String {
        [title, "\(amount) \(AppString.currencySymbol)", subtitle]
            .compactMap { $0 }
            .joined(separator: ", ")
    }

    // MARK: - Methods

    /// «Kaspi Gold → Наличные»; счет удален — его сторона пустая
    static func route(of transfer: Transaction) -> String {
        AppString.transferRoute(
            from: transfer.fromAccount?.name ?? "",
            to: transfer.toAccount?.name ?? ""
        )
    }
}

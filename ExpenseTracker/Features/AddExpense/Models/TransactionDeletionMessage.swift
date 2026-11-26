//
//  TransactionDeletionMessage.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import Foundation

/// Текст алерта «Удалить операцию?»: ««Продукты на неделю» −4 850 ₸. Баланс счёта пересчитается.»
/// Общий для главной и экрана редактирования
enum TransactionDeletionMessage {

    /// Операция называется заметкой, без нее — категорией. Перевод — заметкой или маршрутом
    static func text(for transaction: Transaction) -> String {
        let note = transaction.note.flatMap { $0.isEmpty ? nil : $0 }

        if transaction.kind == .transfer {
            let title = note ?? TransactionRowModel.route(of: transaction)
            let amount = MoneyFormat.money(transaction.amount)
            return AppString.deleteTransferMessage(title: title, amount: amount)
        }
        let title = note ?? transaction.category?.name ?? AppString.noCategory
        let signed = transaction.type == .income ? transaction.amount : -transaction.amount
        let amount = MoneyFormat.signed(signed) + AppString.amountGroupingSeparator + AppString.currencySymbol

        return AppString.deleteTransactionMessage(title: title, amount: amount)
    }
}

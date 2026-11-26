import Foundation
import SwiftData

enum TransferValidationError: Error, Equatable {
    case nonPositiveAmount
    case sameAccount
    case unavailableAccount
}

/// Данные для создания, обновления и восстановления операции после удаления.
struct TransactionDraft {
    let amount: Decimal
    let date: Date
    let note: String?
    let kind: TransactionKind
    let category: Category?
    let account: Account?
    let fromAccount: Account?
    let toAccount: Account?

    init(
        amount: Decimal,
        date: Date,
        note: String? = nil,
        type: TransactionType,
        category: Category? = nil,
        account: Account? = nil
    ) {
        self.amount = amount
        self.date = date
        self.note = note
        kind = TransactionKind(type)
        self.category = category
        self.account = account
        fromAccount = nil
        toAccount = nil
    }

    init(amount: Decimal, date: Date, note: String? = nil, fromAccount: Account, toAccount: Account) {
        self.amount = amount
        self.date = date
        self.note = note
        kind = .transfer
        category = nil
        account = nil
        self.fromAccount = fromAccount
        self.toAccount = toAccount
    }

    init(_ transaction: Transaction) {
        amount = transaction.amount
        date = transaction.date
        note = transaction.note
        kind = transaction.kind
        category = transaction.category
        account = transaction.account
        fromAccount = transaction.fromAccount
        toAccount = transaction.toAccount
    }

    func validate() throws {
        guard kind == .transfer else { return }
        guard !amount.isNaN, amount > .zero else { throw TransferValidationError.nonPositiveAmount }
        guard let fromAccount, let toAccount, !fromAccount.isDeleted, !toAccount.isDeleted else {
            throw TransferValidationError.unavailableAccount
        }
        guard fromAccount.persistentModelID != toAccount.persistentModelID else {
            throw TransferValidationError.sameAccount
        }
    }
}

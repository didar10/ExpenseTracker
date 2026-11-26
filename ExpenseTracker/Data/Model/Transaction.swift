import Foundation
import SwiftData

@Model
final class Transaction {
    private(set) var amount: Decimal
    private(set) var date: Date
    private(set) var note: String?
    private(set) var kind: TransactionKind

    @Relationship private(set) var category: Category?
    @Relationship private(set) var account: Account?
    @Relationship private(set) var fromAccount: Account?
    @Relationship private(set) var toAccount: Account?

    /// Тип для экранов и расчетов, которые работают только с доходами и расходами.
    var type: TransactionType? { kind.entryType }

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
    }

    init(validating draft: TransactionDraft) throws {
        try draft.validate()
        amount = draft.amount
        date = draft.date
        note = draft.note
        kind = draft.kind
        category = draft.category
        account = draft.account
        fromAccount = draft.fromAccount
        toAccount = draft.toAccount
    }

    func apply(_ draft: TransactionDraft) throws {
        try draft.validate()
        assign(draft)
    }

    private func assign(_ draft: TransactionDraft) {
        amount = draft.amount
        date = draft.date
        note = draft.note
        kind = draft.kind
        category = draft.category
        account = draft.account
        fromAccount = draft.fromAccount
        toAccount = draft.toAccount
    }

    /// Доход или расход со знаком, перевод исключен из финансового результата.
    var netIncome: Decimal {
        switch kind {
        case .income: amount
        case .expense: -amount
        case .transfer: 0
        }
    }

    func involves(_ account: Account) -> Bool {
        let id = account.persistentModelID
        if kind == .transfer {
            return fromAccount?.persistentModelID == id || toAccount?.persistentModelID == id
        }
        return self.account?.persistentModelID == id
    }
}

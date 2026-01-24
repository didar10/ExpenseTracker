//
//  Transaction.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import Foundation
import SwiftData

@Model
final class Transaction {

    var amount: Decimal
    var date: Date
    var note: String?
    var type: TransactionType

    @Relationship
    var category: Category?
    
    @Relationship
    var account: Account?

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
        self.type = type
        self.category = category
        self.account = account
    }
}

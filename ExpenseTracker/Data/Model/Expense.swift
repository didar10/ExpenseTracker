//
//  Expense.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import Foundation
import SwiftData

@Model
final class Expense {

    @Attribute(.unique)
    var id: UUID

    var amount: Decimal
    var date: Date
    var note: String?

    @Relationship
    var category: Category?

    init(
        amount: Decimal,
        date: Date = .now,
        note: String? = nil,
        category: Category?
    ) {
        self.id = UUID()
        self.amount = amount
        self.date = date
        self.note = note
        self.category = category
    }
}


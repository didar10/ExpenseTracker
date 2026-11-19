//
//  Category.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import Foundation
import SwiftData

@Model
final class Category {

    @Attribute(.unique)
    var id: UUID

    var name: String
    var icon: String
    var colorHex: String
    var type: TransactionType = TransactionType.expense

    /// Удаление категории оставляет операции без категории, а не удаляет их
    @Relationship(deleteRule: .nullify, inverse: \Transaction.category)
    var transactions: [Transaction] = []

    /// Бюджет без категории не имеет смысла — удаляется вместе с ней
    @Relationship(deleteRule: .cascade, inverse: \BudgetPlan.category)
    var budgetPlans: [BudgetPlan] = []

    init(
        name: String,
        icon: String,
        colorHex: String,
        type: TransactionType = .expense
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.type = type
    }
}

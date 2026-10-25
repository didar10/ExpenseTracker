//
//  SchemaV1.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation
import SwiftData

/// Первая версия схемы — та, с которой приложение работало до появления миграций.
///
/// Модели заморожены: это точная копия хранимых полей на момент выпуска версии,
/// без вычисляемых свойств. Менять их нельзя — по ним SwiftData узнает старую базу
enum SchemaV1: VersionedSchema {

    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            Transaction.self,
            Category.self,
            Account.self,
            BudgetPlan.self
        ]
    }
}

// MARK: - Models

extension SchemaV1 {

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

    @Model
    final class Category {

        @Attribute(.unique)
        var id: UUID

        var name: String
        var icon: String
        var colorHex: String
        var type: TransactionType = TransactionType.expense

        init(name: String, icon: String, colorHex: String, type: TransactionType = .expense) {
            self.id = UUID()
            self.name = name
            self.icon = icon
            self.colorHex = colorHex
            self.type = type
        }
    }

    @Model
    final class Account {

        var name: String
        var icon: String
        var color: String
        var initialBalance: Decimal
        var createdAt: Date
        var isDefault: Bool

        @Relationship(deleteRule: .cascade, inverse: \SchemaV1.Transaction.account)
        var transactions: [Transaction] = []

        init(
            name: String,
            icon: String = "creditcard.fill",
            color: String = "blue",
            initialBalance: Decimal = 0,
            isDefault: Bool = false
        ) {
            self.name = name
            self.icon = icon
            self.color = color
            self.initialBalance = initialBalance
            self.createdAt = Date()
            self.isDefault = isDefault
        }
    }

    @Model
    final class BudgetPlan {

        var category: Category
        var monthlyLimit: Decimal
        var period: BudgetPeriod
        var createdAt: Date
        var isActive: Bool

        init(category: Category, monthlyLimit: Decimal, period: BudgetPeriod = .month, isActive: Bool = true) {
            self.category = category
            self.monthlyLimit = monthlyLimit
            self.period = period
            self.createdAt = Date()
            self.isActive = isActive
        }
    }
}

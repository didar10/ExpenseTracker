//
//  Account.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Account {
    
    var name: String
    var icon: String
    var color: String
    var initialBalance: Decimal
    var createdAt: Date
    var isDefault: Bool
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.account)
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
    
    /// Текущий баланс счета (начальный баланс + все транзакции)
    var currentBalance: Decimal {
        var balance = initialBalance
        
        for transaction in transactions {
            if transaction.type == .income {
                balance += transaction.amount
            } else {
                balance -= transaction.amount
            }
        }
        
        return balance
    }
    
    /// Общий доход по счету
    var totalIncome: Decimal {
        transactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// Общие расходы по счету
    var totalExpenses: Decimal {
        transactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// Преобразование строки цвета в SwiftUI Color
    var swiftUIColor: Color {
        Color(named: color)
    }
}

//
//  BalanceData.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import Foundation

/// Модель для хранения данных о балансе и финансовых показателях
struct BalanceData {
    let balance: Decimal
    let totalIncome: Decimal
    let totalExpenses: Decimal
    
    /// Инициализатор для транзакций (обратная совместимость)
    init(transactions: [Transaction]) {
        var income: Decimal = 0
        var expenses: Decimal = 0

        for transaction in transactions {
            switch transaction.kind {
            case .income: income += transaction.amount
            case .expense: expenses += transaction.amount
            case .transfer: break
            }
        }

        balance = income - expenses
        totalIncome = income
        totalExpenses = expenses
    }

    /// Инициализатор для счетов (общий баланс всех счетов)
    init(accounts: [Account]) {
        var totalBalance: Decimal = 0
        var totalIncome: Decimal = 0
        var totalExpenses: Decimal = 0
        
        for account in accounts {
            totalBalance += account.currentBalance
            totalIncome += account.totalIncome
            totalExpenses += account.totalExpenses
        }
        
        self.balance = totalBalance
        self.totalIncome = totalIncome
        self.totalExpenses = totalExpenses
    }
}

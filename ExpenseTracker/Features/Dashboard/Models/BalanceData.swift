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
        var balance: Decimal = 0
        var income: Decimal = 0
        var expenses: Decimal = 0
        
        for transaction in transactions {
            if transaction.type == .income {
                balance += transaction.amount
                income += transaction.amount
            } else {
                balance -= transaction.amount
                expenses += transaction.amount
            }
        }
        
        self.balance = balance
        self.totalIncome = income
        self.totalExpenses = expenses
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

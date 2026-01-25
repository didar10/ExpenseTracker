//
//  AccountSeeder.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import Foundation
import SwiftData

struct AccountSeeder {
    
    /// Создает счет по умолчанию, если в базе нет счетов
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Account>()
        
        guard let count = try? context.fetchCount(descriptor),
              count == 0 else {
            return
        }
        
        // Создаем основной счет по умолчанию
        let defaultAccount = Account(
            name: "Основной счет",
            icon: "creditcard.fill",
            color: "blue",
            initialBalance: 0,
            isDefault: true
        )
        
        context.insert(defaultAccount)
        
        try? context.save()
        
        print("✅ Создан счет по умолчанию")
    }
}

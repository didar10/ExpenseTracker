//
//  CategorySeeder.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import Foundation
import SwiftData

@MainActor
struct CategorySeeder {

    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Category>()

        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        let defaults: [(String, String, String, TransactionType)] = [
            // Расходы
            ("Еда", "fork.knife", "#34C759", .expense),
            ("Транспорт", "car.fill", "#007AFF", .expense),
            ("Покупки", "cart.fill", "#FF9500", .expense),
            ("Дом", "house.fill", "#AF52DE", .expense),
            ("Развлечения", "gamecontroller.fill", "#FF2D55", .expense),
            // Доходы
            ("Зарплата", "banknote.fill", "#34C759", .income),
            ("Подработка", "briefcase.fill", "#007AFF", .income),
            ("Подарок", "gift.fill", "#FF2D55", .income),
            ("Инвестиции", "chart.line.uptrend.xyaxis", "#5856D6", .income)
        ]

        defaults.forEach {
            context.insert(
                Category(
                    name: $0.0,
                    icon: $0.1,
                    colorHex: $0.2,
                    type: $0.3
                )
            )
        }
    }
}

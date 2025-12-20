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

        let defaults: [(String, String, String)] = [
            ("Еда", "fork.knife", "#34C759"),
            ("Транспорт", "car.fill", "#007AFF"),
            ("Покупки", "cart.fill", "#FF9500"),
            ("Дом", "house.fill", "#AF52DE"),
            ("Развлечения", "gamecontroller.fill", "#FF2D55")
        ]

        defaults.forEach {
            context.insert(
                Category(
                    name: $0.0,
                    icon: $0.1,
                    colorHex: $0.2
                )
            )
        }
    }
}

//
//  CategoryCarouselOrderTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 25.11.2026.
//

import Foundation
import SwiftUI
import Testing
@testable import ExpenseTracker

struct CategoryCarouselOrderTests {

    private func category(_ title: String, spend: Decimal) -> CarouselCategory {
        CarouselCategory(id: UUID(), title: title, icon: Image(systemName: "circle"), color: .clear, monthlySpend: spend)
    }

    @Test func biggerSpendComesFirst() {
        let ordered = CarouselCategory.orderedBySpend([
            category("Транспорт", spend: 7_200),
            category("Покупки", spend: 28_500),
            category("Продукты", spend: 18_400)
        ])

        #expect(ordered.map(\.title) == ["Покупки", "Продукты", "Транспорт"])
    }

    @Test func equalSpendKeepsOriginalOrder() {
        let ordered = CarouselCategory.orderedBySpend([
            category("Связь", spend: 0),
            category("Спорт", spend: 6_000),
            category("Образование", spend: 0),
            category("Подарки", spend: 0)
        ])

        #expect(ordered.map(\.title) == ["Спорт", "Связь", "Образование", "Подарки"])
    }
}

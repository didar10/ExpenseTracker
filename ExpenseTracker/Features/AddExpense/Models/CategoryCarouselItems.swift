//
//  CategoryCarouselItems.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Категории из данных в виде плиток ленты и строк списка категорий
enum CategoryCarouselItems {

    // MARK: - Methods

    /// Плитки в исходном порядке; для ленты их сортирует `CarouselCategory.orderedBySpend`.
    /// Подпись «18 400 ₸ в ноябре» — только у категорий с тратами за месяц
    static func make(
        from categories: [Category],
        spending: [UUID: Decimal],
        calendar: Calendar = .current,
        now: Date = .now
    ) -> [CarouselCategory] {
        let month = calendar.component(.month, from: now)

        return categories.map { category in
            let spend = spending[category.id] ?? .zero

            return CarouselCategory(
                id: category.id,
                title: category.name,
                icon: Image(systemName: category.icon),
                color: DS.CategoryColor(legacyHex: category.colorHex).color,
                monthlySpend: spend,
                spendCaption: spend > .zero ? AppString.spentInMonth(MoneyFormat.money(spend), month: month) : nil
            )
        }
    }
}

//
//  CategoryBudgetItem.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftData
import SwiftUI

/// Строка бюджета категории за показанный месяц
struct CategoryBudgetItem: Identifiable, Equatable {

    // MARK: - Types

    /// Цвет бейджа с процентом
    enum Status: Equatable {
        /// До 79%
        case normal
        /// 80–99%
        case warning
        /// 100% и больше
        case exceeded
    }

    // MARK: - Properties

    let id: PersistentIdentifier
    let name: String
    let iconName: String
    let color: DS.CategoryColor
    let spent: Decimal
    let limit: Decimal
    /// Остаток поровну на оставшиеся дни, без копеек; nil — месяц закончился или лимит исчерпан
    let perDay: Decimal?
    /// Прошедшая доля месяца для метки на полосе; nil — месяц закончился
    let paceMarker: Double?

    // MARK: - Computed Properties

    /// Доля потраченного; больше 1 — превышение
    var progress: Double {
        guard limit > 0 else { return spent > 0 ? .infinity : 0 }
        return NSDecimalNumber(decimal: spent / limit).doubleValue
    }

    /// Процент без дробной части, вниз: 99,9% — еще не 100
    var percent: Int {
        guard limit > 0 else { return spent > 0 ? Constants.exceededPercent : 0 }

        // В Decimal: в Double 0,8 × 100 может дать 79,999… и уронить бейдж на ступень ниже
        var source = spent * Decimal(Constants.percentScale) / limit
        var result = Decimal()
        NSDecimalRound(&result, &source, 0, .down)
        return NSDecimalNumber(decimal: result).intValue
    }

    var status: Status {
        switch percent {
        case ..<Constants.warningPercent: return .normal
        case ..<Constants.exceededPercent: return .warning
        default: return .exceeded
        }
    }

    var remaining: Decimal {
        max(limit - spent, 0)
    }

    var overspent: Decimal {
        max(spent - limit, 0)
    }

    var icon: Image {
        Image(systemName: iconName)
    }
}

// MARK: - Constants

extension CategoryBudgetItem {

    enum Constants {
        static let percentScale: Double = 100
        static let warningPercent = 80
        static let exceededPercent = 100
    }
}

//
//  CategoryStatistic.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Модель для хранения статистики по категории
struct CategoryStatistic: Identifiable {

    // MARK: - Properties

    /// Идентификатор категории, а не новый UUID: иначе пересчет статистики
    /// подменяет все строки списка и сбрасывает выделенный сектор диаграммы
    var id: UUID { category.id }

    let category: Category
    let amount: Decimal
    let transactionCount: Int

    // MARK: - Computed Properties

    /// Цвет сектора и плитки: токен DS, ближайший к цвету категории
    var color: DS.CategoryColor {
        DS.CategoryColor(legacyHex: category.colorHex)
    }

    var icon: Image {
        Image(systemName: category.icon)
    }

    // MARK: - Methods

    /// Сумма со знаком типа: «−65 000», «+480 000»
    func signedAmount(for type: TransactionType) -> String {
        MoneyFormat.signed(type == .income ? amount : -amount)
    }

    /// Длина полосы в списке — относительно самой большой категории, 0…1
    func barFraction(relativeTo maxAmount: Decimal) -> Double {
        guard maxAmount > 0 else { return 0 }
        return min(((amount / maxAmount) as NSDecimalNumber).doubleValue, 1)
    }

    /// Доля от общей суммы: 0…1
    func percentage(of total: Decimal) -> Double {
        guard total > 0 else { return 0 }
        return ((amount / total) as NSDecimalNumber).doubleValue
    }

    /// Процент для показа. Округляем, а не отбрасываем дробную часть:
    /// иначе 35,99 % превращается в 35 %, и сумма долей не дотягивает до 100 %
    func percentageString(of total: Decimal) -> String {
        let value = Int((percentage(of: total) * 100).rounded())
        return "\(value)%"
    }
}

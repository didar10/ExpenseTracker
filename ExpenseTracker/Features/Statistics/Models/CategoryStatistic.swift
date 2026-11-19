//
//  CategoryStatistic.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import Foundation

/// Модель для хранения статистики по категории
struct CategoryStatistic: Identifiable {

    // MARK: - Properties

    /// Идентификатор категории, а не новый UUID: иначе пересчет статистики
    /// подменяет все строки списка и сбрасывает выделенный сектор диаграммы
    var id: UUID { category.id }

    let category: Category
    let amount: Decimal
    let transactionCount: Int

    // MARK: - Methods

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

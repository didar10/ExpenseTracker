//
//  MonthlyLimitOverview.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Карточка «Лимит на месяц»: остаток, траты по категориям, сумма на день и темп
struct MonthlyLimitOverview: Equatable {

    // MARK: - Properties

    let limit: Decimal
    let spent: Decimal
    /// Отрезки составной полосы: доля каждой категории от лимита
    let segments: [SpendingSegment]
    /// Оставшиеся дни месяца, включая сегодня; nil — месяц уже закончился
    let daysLeft: Int?
    /// Остаток поровну на оставшиеся дни, без копеек; nil — месяц закончился
    let perDay: Decimal?
    /// nil — месяц закончился
    let pace: LimitPace?

    // MARK: - Computed Properties

    /// Отрицательный — лимит превышен
    var remaining: Decimal {
        limit - spent
    }

    var isExceeded: Bool {
        remaining < 0
    }
}

/// Отрезок составной полосы лимита
struct SpendingSegment: Identifiable, Equatable {

    // MARK: - Properties

    let id: String
    /// nil — траты без категории
    let color: DS.CategoryColor?
    /// Доля от шкалы полосы, 0…1
    let fraction: Double

    // MARK: - Computed Properties

    var fill: Color {
        color?.color ?? DS.Color.noCategory
    }
}

/// Темп трат по лимиту: сколько потрачено против «плана» —
/// доли лимита, пропорциональной прошедшим дням месяца, включая сегодня
struct LimitPace: Equatable {

    // MARK: - Properties

    /// Отклонение от плана в процентах, без знака
    let percent: Int
    /// Тратим быстрее плана: к концу месяца лимит закончится раньше
    let isFaster: Bool

    // MARK: - Init

    init(percent: Int, isFaster: Bool) {
        self.percent = percent
        self.isFaster = isFaster
    }

    /// nil — плана еще нет: лимит или прошедшая доля месяца нулевые
    init?(spent: Decimal, limit: Decimal, elapsedFraction: Double) {
        guard limit > 0, elapsedFraction > 0 else { return nil }

        let planned = NSDecimalNumber(decimal: limit).doubleValue * elapsedFraction
        let ratio = NSDecimalNumber(decimal: spent).doubleValue / planned

        self.percent = Int((abs(1 - ratio) * Constants.percentScale).rounded())
        self.isFaster = ratio > 1
    }
}

// MARK: - Constants

private extension LimitPace {

    enum Constants {
        static let percentScale: Double = 100
    }
}

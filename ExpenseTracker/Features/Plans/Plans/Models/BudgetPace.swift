//
//  BudgetPace.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation

/// Темп трат по бюджету: потраченная доля лимита против прошедшей доли периода.
///
/// 60% лимита к 20-му числу из 30 — нормально, а 60% к 5-му — уже тревожно.
/// Фиксированные пороги (70% / 90%) этого не различали
struct BudgetPace: Equatable {

    enum Level: Equatable {
        /// Тратим не быстрее, чем идет время
        case onTrack
        /// Тратим быстрее, чем идет время: к концу периода лимит закончится раньше
        case ahead
        /// Лимит превышен
        case over
    }

    // MARK: - Properties

    /// Потраченная доля лимита; больше 1 — лимит превышен
    let spentFraction: Double
    /// Прошедшая доля периода, 0...1; nil — период уже закончился
    let elapsedFraction: Double?

    // MARK: - Computed Properties

    /// Заполнение полоски прогресса, 0...1
    var progress: Double {
        min(max(spentFraction, 0), 1)
    }

    var level: Level {
        if spentFraction > 1 { return .over }

        guard let elapsedFraction else { return .onTrack }

        return spentFraction - elapsedFraction > Constants.aheadTolerance ? .ahead : .onTrack
    }

    // MARK: - Init

    init(spent: Decimal, limit: Decimal, interval: DateInterval, now: Date = .now) {
        if limit > 0 {
            spentFraction = NSDecimalNumber(decimal: spent / limit).doubleValue
        } else {
            spentFraction = spent > 0 ? .infinity : 0
        }

        elapsedFraction = Self.elapsedFraction(of: interval, now: now)
    }

    // MARK: - Private Methods

    private static func elapsedFraction(of interval: DateInterval, now: Date) -> Double? {
        guard now < interval.end else { return nil }
        guard now > interval.start, interval.duration > 0 else { return 0 }

        return now.timeIntervalSince(interval.start) / interval.duration
    }
}

// MARK: - Constants

private extension BudgetPace {

    enum Constants {
        /// Насколько можно опережать время, прежде чем предупреждать:
        /// одна крупная покупка в начале периода не должна сразу красить полоску
        static let aheadTolerance = 0.1
    }
}

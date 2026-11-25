//
//  CategoryStatisticTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 25.11.2026.
//

import Foundation
import Testing
@testable import ExpenseTracker

/// Строка «По категориям»: сумма со знаком, длина полосы, процент
@MainActor
struct CategoryStatisticTests {

    private func statistic(_ amount: Decimal) -> CategoryStatistic {
        CategoryStatistic(
            category: ExpenseTracker.Category(name: "Дом", icon: "house", colorHex: "#AF52DE"),
            amount: amount,
            transactionCount: 1
        )
    }

    @Test func amountSignFollowsType() {
        #expect(statistic(65_000).signedAmount(for: .expense) == "−65\u{00A0}000")
        #expect(statistic(480_000).signedAmount(for: .income) == "+480\u{00A0}000")
    }

    @Test func barIsRelativeToLargestCategory() {
        #expect(statistic(65_000).barFraction(relativeTo: 65_000) == 1)
        #expect(abs(statistic(28_500).barFraction(relativeTo: 65_000) - 0.4385) < 0.001)
        #expect(statistic(100).barFraction(relativeTo: 0) == 0)
    }

    @Test func percentMatchesMockup() {
        #expect(statistic(65_000).percentageString(of: 131_950) == "49%")
        #expect(statistic(8_500).percentageString(of: 131_950) == "6%")
    }

    @Test func colorMapsLegacyHexToToken() {
        #expect(statistic(1).color == .purple)
    }
}

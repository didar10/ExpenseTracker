//
//  CategoryPieChartRenderTests.swift
//  ExpenseTrackerTests
//

import SwiftUI
import UIKit
import Testing
@testable import ExpenseTracker

/// Контейнер данных диаграммы для анимированной смены статистики в тестах
@MainActor
@Observable
final class ChartBox {
    var statistics: [CategoryStatistic] = []
    var totalAmount: Decimal = 0
}

/// Обертка, повторяющая условия экрана статистики: диаграмма скрывается при пустых данных
struct ChartHarness: View {
    @Bindable var box: ChartBox

    var body: some View {
        VStack {
            if box.statistics.isEmpty {
                AppText(AppString.noData, style: .caption)
            } else {
                CategoryPieChartView(
                    statistics: box.statistics,
                    totalAmount: box.totalAmount,
                    title: AppString.expenses
                )
            }
        }
    }
}

/// Регрессия на краш Charts при анимированной смене набора секторов
/// (переключение Расход/Доход, смена счета или периода внутри withAnimation)
@MainActor
@Suite(.serialized)
struct CategoryPieChartRenderTests {

    // MARK: - Helpers

    private func statistic(_ name: String, _ amount: Decimal) -> CategoryStatistic {
        CategoryStatistic(
            category: Category(name: name, icon: "banknote.fill", colorHex: "#34C759", type: .income),
            amount: amount,
            transactionCount: 1
        )
    }

    private var expenseStatistics: [CategoryStatistic] {
        [
            statistic("Еда", 50000),
            statistic("Транспорт", 30000),
            statistic("Покупки", 20000),
            statistic("Дом", 10000),
            statistic("Развлечения", 5000)
        ]
    }

    private func renderTransition(to newStatistics: [CategoryStatistic], totalAmount: Decimal) {
        let box = ChartBox()
        box.statistics = expenseStatistics
        box.totalAmount = 115000

        let controller = UIHostingController(rootView: ChartHarness(box: box))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = controller
        window.isHidden = false
        controller.view.layoutIfNeeded()
        RunLoop.current.run(until: Date().addingTimeInterval(0.5))

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            box.statistics = newStatistics
            box.totalAmount = totalAmount
        }
        controller.view.layoutIfNeeded()
        RunLoop.current.run(until: Date().addingTimeInterval(1.5))
    }

    // MARK: - Tests

    @Test func rendersTransitionToSingleCategory() {
        renderTransition(to: [statistic("Зарплата", 500000)], totalAmount: 500000)
    }

    @Test func rendersTransitionToEmptyStatistics() {
        renderTransition(to: [], totalAmount: 0)
    }

    @Test func rendersTransitionToTwoCategories() {
        renderTransition(
            to: [statistic("Зарплата", 500000), statistic("Подарок", 20000)],
            totalAmount: 520000
        )
    }

    @Test func rendersTransitionToTwoEvenCategories() {
        renderTransition(
            to: [statistic("Зарплата", 300000), statistic("Подарок", 200000)],
            totalAmount: 500000
        )
    }
}

//
//  StatisticsView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {

    @Query(sort: \Transaction.date, order: .reverse)
    private var transactions: [Transaction]

    @State private var selectedMonth: Date = .now

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                monthPicker

                totalExpensesView

                if !expensesByCategory.isEmpty {
                    pieChart
                    categoriesList
                } else {
                    emptyState
                }
            }
            .padding()
        }
        .navigationTitle("Статистика")
    }
}

private extension StatisticsView {

    var monthPicker: some View {
        HStack {
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text(selectedMonthTitle)
                .font(.app(.section))

            Spacer()

            Button {
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
    }

    var selectedMonthTitle: String {
        selectedMonth.formatted(
            Date.FormatStyle()
                .month(.wide)
                .year()
        )
        .capitalized
    }

    func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(
            byAdding: .month,
            value: value,
            to: selectedMonth
        ) {
            selectedMonth = newDate
        }
    }
}

private extension StatisticsView {

    var totalExpensesView: some View {
        VStack(spacing: 4) {
            Text("Всего расходов")
                .font(.app(.section))
                .foregroundColor(.secondary)

            Text(totalExpenses.formatted(.currency(code: "KZT")))
                .font(.app(.largeTitle))
                .foregroundColor(.red)
        }
    }

    var totalExpenses: Decimal {
        expenses.reduce(0) { $0 + $1.amount }
    }
}

private extension StatisticsView {

    struct CategoryStat: Identifiable {
        let id = UUID()
        let category: Category
        let amount: Decimal
    }

    var selectedMonthInterval: DateInterval {
        Calendar.current.dateInterval(of: .month, for: selectedMonth)!
    }

    var expenses: [Transaction] {
        transactions.filter {
            $0.type == .expense &&
            selectedMonthInterval.contains($0.date)
        }
    }

    var expensesByCategory: [CategoryStat] {
        let grouped = Dictionary(grouping: expenses) {
            $0.category
        }

        return grouped.compactMap { category, transactions in
            guard let category else { return nil }

            let sum = transactions.reduce(0) { $0 + $1.amount }

            return CategoryStat(category: category, amount: sum)
        }
        .sorted { $0.amount > $1.amount }
    }
}

private extension StatisticsView {

    var pieChart: some View {
        Chart {
            ForEach(expensesByCategory) { stat in
                SectorMark(
                    angle: .value("Сумма", stat.amount),
                    innerRadius: .ratio(0.55)
                )
                .foregroundStyle(Color(hex: stat.category.colorHex))
                .annotation(position: .overlay) {
                    if stat.amount / totalExpenses > 0.15 {
                        Image(systemName: stat.category.icon)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .frame(height: 240)
    }
}

private extension StatisticsView {

    var categoriesList: some View {
        VStack(spacing: 12) {
            ForEach(expensesByCategory) { stat in
                categoryRow(stat)
            }
        }
    }

    func categoryRow(_ stat: CategoryStat) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: stat.category.colorHex))
                    .frame(width: 36, height: 36)

                Image(systemName: stat.category.icon)
                    .foregroundColor(.white)
            }

            Text(stat.category.name)
                .font(.app(.body))

            Spacer()

            Text(stat.amount.formatted(.currency(code: "KZT")))
                .font(.app(.body))
                .foregroundColor(.secondary)
        }
    }
}

private extension StatisticsView {

    var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.largeTitle)
                .foregroundColor(.secondary)

            Text("Нет данных за выбранный месяц")
                .foregroundColor(.secondary)
        }
        .padding(.top, 40)
    }
}

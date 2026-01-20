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
    @State private var scrollOffset: CGFloat = 0
    @Environment(\.tabBarVisibility) private var isTabBarVisible

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Fixed header
                customHeader
                
                ScrollView {
                    VStack(spacing: 16) {
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
                    .padding(.bottom, 100)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
}

private extension StatisticsView {
    
    var customHeader: some View {
        Text("Статистика")
            .font(.system(size: 20, weight: .semibold))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 16)
            .background(Color(.systemGroupedBackground))
    }

    var monthPicker: some View {
        HStack(spacing: 16) {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.green)
                    .symbolRenderingMode(.hierarchical)
            }

            Spacer()

            Text(selectedMonthTitle)
                .font(.system(size: 18, weight: .bold))
                .contentTransition(.numericText())

            Spacer()

            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.green)
                    .symbolRenderingMode(.hierarchical)
            }
            .disabled(isCurrentMonth)
            .opacity(isCurrentMonth ? 0.3 : 1.0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
    }
    
    var isCurrentMonth: Bool {
        Calendar.current.isDate(selectedMonth, equalTo: .now, toGranularity: .month)
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
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if let newDate = Calendar.current.date(
                byAdding: .month,
                value: value,
                to: selectedMonth
            ) {
                selectedMonth = newDate
            }
        }
    }
}

private extension StatisticsView {

    var totalExpensesView: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.red)
                
                Text("Всего расходов")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                
                Spacer()
            }

            Text(totalExpenses.formatted(.currency(code: "KZT")))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentTransition(.numericText())
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
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
    
    func categoryTransactions(for category: Category) -> [Transaction] {
        expenses.filter { $0.category == category }
    }
}

private extension StatisticsView {

    var pieChart: some View {
        VStack(spacing: 12) {
            Chart {
                ForEach(expensesByCategory) { stat in
                    SectorMark(
                        angle: .value("Сумма", stat.amount),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(Color(hex: stat.category.colorHex).gradient)
                    .annotation(position: .overlay) {
                        if stat.amount / totalExpenses > 0.12 {
                            VStack(spacing: 4) {
                                Image(systemName: stat.category.icon)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .shadow(radius: 2)
                            }
                        }
                    }
                }
            }
            .frame(height: 220)
            .chartBackground { _ in
                VStack(spacing: 3) {
                    Text("Расходы")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Text(totalExpenses.formatted(.currency(code: "KZT")))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
    }
}

private extension StatisticsView {

    var categoriesList: some View {
        VStack(spacing: 0) {
            ForEach(Array(expensesByCategory.enumerated()), id: \.element.id) { index, stat in
                categoryRow(stat, percentage: (stat.amount / totalExpenses))
                
                if index < expensesByCategory.count - 1 {
                    Divider()
                        .padding(.leading, 60)
                }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
    }

    func categoryRow(_ stat: CategoryStat, percentage: Decimal) -> some View {
        NavigationLink {
            CategoryTransactionsView(
                category: stat.category,
                month: selectedMonth,
                transactions: categoryTransactions(for: stat.category)
            )
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: stat.category.colorHex).opacity(0.15))
                        .frame(width: 38, height: 38)

                    Image(systemName: stat.category.icon)
                        .foregroundStyle(Color(hex: stat.category.colorHex))
                        .font(.system(size: 18, weight: .semibold))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(stat.category.name)
                        .font(.system(size: 15, weight: .semibold))
                    
                    Text("\(Int((percentage as NSDecimalNumber).doubleValue * 100))%")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 8) {
                    Text(stat.amount.formatted(.currency(code: "KZT")))
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
    }
}

private extension StatisticsView {

    var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: 6) {
                Text("Нет данных")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Добавьте расходы за выбранный месяц")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
    }
}

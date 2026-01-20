//
//  DashboardView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI
import SwiftData

struct DashboardView: View {

    @Query(sort: \Transaction.date, order: .reverse)
    private var transactions: [Transaction]
    
    @State private var selectedTransaction: Transaction?
    @State private var scrollOffset: CGFloat = 0
    @Environment(\.tabBarVisibility) private var isTabBarVisible

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Fixed header
                customHeader
                
                ScrollView {
                    VStack(spacing: 20) {
                        balanceCard
                        
                        transactionsList
                    }
                    .padding(.bottom, 100)
//                    .trackScrollOffset(
//                        in: "dashboardScroll",
//                        offset: $scrollOffset,
//                        tabBarVisible: isTabBarVisible
//                    )
                }
                .coordinateSpace(name: "dashboardScroll")
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedTransaction) { transaction in
                AddTransactionView(transaction: transaction)
            }
        }
    }
}

// MARK: - Header
private extension DashboardView {
    
    var customHeader: some View {
        Text("Главная")
            .font(.system(size: 20, weight: .semibold))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 16)
            .background(Color(.systemGroupedBackground))
    }

    var balanceCard: some View {
        VStack(spacing: 12) {
            Text("Баланс")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
            
            Text(balance.formatted(.currency(code: "KZT")))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
            
            HStack(spacing: 24) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.green)
                    
                    Text(totalIncome.formatted(.currency(code: "KZT")))
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.red)
                    
                    Text(totalExpenses.formatted(.currency(code: "KZT")))
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                }
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 24)
        .padding(.horizontal)
    }

    var balance: Decimal {
        transactions.reduce(0) { result, transaction in
            transaction.type == .income
            ? result + transaction.amount
            : result - transaction.amount
        }
    }
    
    var totalIncome: Decimal {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpenses: Decimal {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
}

// MARK: - Grouping
private extension DashboardView {

    struct TransactionSection {
        let date: Date
        let transactions: [Transaction]
    }

    var groupedTransactions: [TransactionSection] {
        let grouped = Dictionary(grouping: transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }

        return grouped
            .map { TransactionSection(date: $0.key, transactions: $0.value) }
            .sorted { $0.date > $1.date }
    }
}

// MARK: - UI helpers
private extension DashboardView {
    
    var transactionsList: some View {
        VStack(spacing: 0) {
            if groupedTransactions.isEmpty {
                emptyState
            } else {
                ForEach(groupedTransactions, id: \.date) { section in
                    VStack(alignment: .leading, spacing: 16) {
                        sectionHeader(for: section.date)
                        
                        VStack(spacing: 8) {
                            ForEach(section.transactions) { transaction in
                                TransactionRowView(transaction: transaction)
                                    .onTapGesture {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        withAnimation {
                                            selectedTransaction = transaction
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color(uiColor: .systemBackground))
                                .shadow(
                                    color: .black.opacity(0.65),
                                    radius: 0,
                                    x: 4,
                                    y: 6
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(Color.black.opacity(0.15), lineWidth: 1.5)
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            }
        }
    }
    
    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)
            
            VStack(spacing: 8) {
                Text("Нет транзакций")
                    .font(.system(size: 20, weight: .semibold))
                
                Text("Нажмите + чтобы добавить первую транзакцию")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }

    func sectionHeader(for date: Date) -> some View {
        Text(dateTitle(for: date))
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal)
            .textCase(.uppercase)
    }

    func dateTitle(for date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Сегодня"
        } else if calendar.isDateInYesterday(date) {
            return "Вчера"
        } else {
            return date.formatted(
                Date.FormatStyle()
                    .day()
                    .month(.wide)
                    .year()
            )
        }
    }
}

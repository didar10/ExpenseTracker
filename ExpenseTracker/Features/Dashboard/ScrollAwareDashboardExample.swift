//
//  ScrollAwareDashboardExample.swift
//  ExpenseTracker
//
//  Created by Didar on 18.01.2026.
//
//  This is an EXAMPLE showing how to use scroll-aware headers
//  You can replace DashboardView with this implementation if you want
//  the header to shrink as you scroll

import SwiftUI
import SwiftData

struct ScrollAwareDashboardExample: View {

    @Query(sort: \Transaction.date, order: .reverse)
    private var transactions: [Transaction]
    
    @State private var selectedTransaction: Transaction?
    @State private var showAddTransaction = false
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Sticky scroll-aware header
                        ScrollAwareNavigationHeader(
                            title: "Главная",
                            subtitle: "Управление финансами",
                            scrollOffset: scrollOffset,
                            trailingButton: HeaderButton(
                                icon: "person.crop.circle.fill",
                                action: {
                                    // Settings action
                                }
                            )
                        )
                        .zIndex(1) // Keep on top
                        
                        // Content starts here
                        VStack(spacing: 20) {
                            balanceCard
                            transactionsList
                        }
                        .trackScrollOffset(in: "scroll", offset: $scrollOffset)
                    }
                    .padding(.bottom, 100)
                }
                .coordinateSpace(name: "scroll")
                .background(Color(.systemGroupedBackground))
                
                addButton
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedTransaction) { transaction in
                NavigationStack {
                    AddTransactionView(transaction: transaction)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showAddTransaction) {
                NavigationStack {
                    AddTransactionView()
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Views (same as DashboardView)
    
    var balanceCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Текущий баланс")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)

                    Text(balance.formatted(.currency(code: "KZT")))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(balance >= 0 ? .green : .red)
                        .contentTransition(.numericText())
                }
                
                Spacer()
                
                Image(systemName: balance >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(balance >= 0 ? .green : .red)
                    .symbolRenderingMode(.hierarchical)
            }
            
            Divider()
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.green)
                        Text("Доходы")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(totalIncome.formatted(.currency(code: "KZT")))
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("Расходы")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.red)
                    }
                    
                    Text(totalExpenses.formatted(.currency(code: "KZT")))
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        }
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
    
    var transactionsList: some View {
        VStack(spacing: 0) {
            if groupedTransactions.isEmpty {
                emptyState
            } else {
                ForEach(groupedTransactions, id: \.date) { section in
                    VStack(alignment: .leading, spacing: 12) {
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
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                        }
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
    
    var addButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            showAddTransaction = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .green.opacity(0.4), radius: 12, y: 6)
                }
        }
        .padding(24)
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

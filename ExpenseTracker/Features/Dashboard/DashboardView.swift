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

    @State private var isAddPresented = false
    
    @State private var selectedTransaction: Transaction?
    @State private var isEditPresented = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List {
                    balanceSection

                    ForEach(groupedTransactions, id: \.date) { section in
                        Section {
                            ForEach(section.transactions) { transaction in
                                TransactionRowView(transaction: transaction)
                                    .onTapGesture {
                                        selectedTransaction = transaction
                                        isEditPresented = true
                                    }
                            }
                        } header: {
                            sectionHeader(for: section.date)
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Главная")
            }
            .sheet(isPresented: $isAddPresented) {
                NavigationStack {
                    AddTransactionView()
                }
            }
            .sheet(isPresented: $isEditPresented) {
                if let transaction = selectedTransaction {
                    NavigationStack {
                        AddTransactionView(transaction: transaction)
                    }
                }
            }
        }
    }
}

// MARK: - Balance
private extension DashboardView {

    var balanceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Баланс")
                .font(.app(.section))
                .foregroundColor(.secondary)

            Text(balance.formatted(.currency(code: "KZT")))
                .font(.app(.largeTitle))
                .bold()
                .foregroundColor(balance >= 0 ? .black : .red)
        }
        .padding(.vertical, 12)
    }

    var balance: Decimal {
        transactions.reduce(0) { result, transaction in
            transaction.type == .income
            ? result + transaction.amount
            : result - transaction.amount
        }
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

    func sectionHeader(for date: Date) -> some View {
        Text(dateTitle(for: date))
            .font(.app(.section))
            .foregroundColor(.primary)
            .textCase(nil)
            .padding(.vertical, 4)
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

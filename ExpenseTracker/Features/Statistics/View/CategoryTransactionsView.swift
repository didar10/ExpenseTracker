//
//  CategoryTransactionsView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.01.2026.
//

import SwiftUI
import SwiftData

struct CategoryTransactionsView: View {
    
    let category: Category
    let month: Date
    let transactions: [Transaction]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            if transactions.isEmpty {
                emptyState
            } else {
                transactionsList
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.green)
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
    }
}

// MARK: - UI Components
private extension CategoryTransactionsView {
    
    var transactionsList: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header card with total
                totalCard
                
                // Transactions grouped by date
                VStack(spacing: 12) {
                    ForEach(groupedTransactions, id: \.date) { group in
                        VStack(spacing: 0) {
                            // Date header
                            HStack {
                                Text(group.date, style: .date)
                                    .font(.app(.sectionHeader))
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                Text(group.total.formatted(.currency(code: "KZT")))
                                    .font(.app(.sectionHeader))
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            
                            // Transactions for this date
                            VStack(spacing: 0) {
                                ForEach(Array(group.transactions.enumerated()), id: \.element.id) { index, transaction in
                                    TransactionRowView(transaction: transaction)
                                        .padding(.horizontal, 16)
                                    
                                    if index < group.transactions.count - 1 {
                                        Divider()
                                            .padding(.leading, 66)
                                    }
                                }
                            }
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                        }
                    }
                }
            }
            .padding()
            .padding(.bottom, 32)
        }
    }
    
    var totalCard: some View {
        VStack(spacing: 12) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: category.colorHex).opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: category.icon)
                        .foregroundStyle(Color(hex: category.colorHex))
                        .font(.system(size: 22, weight: .semibold))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    AppText("Всего транзакций", style: .sectionHeader, color: .secondary)
                    
                    AppText("\(transactions.count)", style: .section)
                }
                
                Spacer()
            }
            
            Divider()
            
            HStack {
                AppText("Сумма", style: .sectionHeader, color: .secondary)
                
                Spacer()
                
                Text(totalAmount.formatted(.currency(code: "KZT")))
                    .font(.app(.title))
                    .fontDesign(.rounded)
                    .foregroundStyle(Color(hex: category.colorHex))
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
    }
    
    var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.system(size: 48))
                .foregroundStyle(Color(hex: category.colorHex).opacity(0.5))
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: 6) {
                AppText("Нет транзакций", style: .section)
                
                AppText("В этом месяце нет транзакций в категории «\(category.name)»", style: .sectionHeader, color: .secondary, alignment: .center)
                    .padding(.horizontal, 32)
            }
        }
    }
}

// MARK: - Data Processing
private extension CategoryTransactionsView {
    
    struct TransactionGroup {
        let date: Date
        let transactions: [Transaction]
        let total: Decimal
    }
    
    var totalAmount: Decimal {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    var groupedTransactions: [TransactionGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }
        
        return grouped.map { date, transactions in
            let sorted = transactions.sorted { $0.date > $1.date }
            let total = transactions.reduce(0) { $0 + $1.amount }
            return TransactionGroup(date: date, transactions: sorted, total: total)
        }
        .sorted { $0.date > $1.date }
    }
}

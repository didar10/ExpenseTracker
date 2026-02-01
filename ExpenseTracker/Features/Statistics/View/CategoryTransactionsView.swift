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
    let period: StatisticsPeriod
    let transactions: [Transaction]
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabBarVisibility) private var isTabBarVisible
    
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
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(category.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    Text(period.rawValue)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.secondary)
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    isTabBarVisible.wrappedValue = true
                    dismiss()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 40, height: 40)
                            .shadow(
                                color: .black.opacity(0.1),
                                radius: 3,
                                x: 0,
                                y: 2
                            )
                        
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.black)
                    }
                }
            }
        }
        .onAppear {
            isTabBarVisible.wrappedValue = false
        }
    }
}

// MARK: - UI Components
private extension CategoryTransactionsView {
    
    var transactionsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header card with total
                totalCard
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                
                // Transactions grouped by date
                VStack(spacing: 0) {
                    ForEach(groupedTransactions, id: \.date) { group in
                        VStack(alignment: .leading, spacing: 8) {
                            // Date header - отдельно от карточек
                            SectionHeaderView(date: group.date)
                                .padding(.bottom, 4)
                            
                            // Transactions for this date - каждая отдельной карточкой
                            ForEach(group.transactions) { transaction in
                                TransactionRowView(transaction: transaction)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .cardShadow(cornerRadius: 12)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }
                }
                .padding(.top, 16)
            }
            .padding(.bottom, 32)
        }
    }
    
    var totalCard: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(hex: category.colorHex).opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: category.icon)
                    .foregroundStyle(Color(hex: category.colorHex))
                    .font(.system(size: 26, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                AppText("Всего за период", style: .sectionHeader, color: .secondary)
                
                Text(totalAmount.formatted(.currency(code: "KZT")))
                    .font(.system(size: 22, weight: .bold))
                    .fontDesign(.rounded)
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
        .padding(16)
        .cardShadow(cornerRadius: 16)
    }
    
    var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.system(size: 48))
                .foregroundStyle(Color(hex: category.colorHex).opacity(0.5))
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: 6) {
                AppText("Нет транзакций", style: .section)
                
                AppText("За выбранный период нет транзакций в категории «\(category.name)»", style: .sectionHeader, color: .secondary, alignment: .center)
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

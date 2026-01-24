//
//  AccountDetailView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI
import SwiftData

struct AccountDetailView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Bindable var account: Account
    
    @State private var showingEditAccount = false
    @State private var showingDeleteAlert = false
    
    private var sortedTransactions: [Transaction] {
        account.transactions.sorted { $0.date > $1.date }
    }
    
    private var groupedTransactions: [(String, [Transaction])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sortedTransactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }
        
        return grouped
            .sorted { $0.key > $1.key }
            .map { date, transactions in
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ru_RU")
                
                if calendar.isDateInToday(date) {
                    return ("Сегодня", transactions.sorted { $0.date > $1.date })
                } else if calendar.isDateInYesterday(date) {
                    return ("Вчера", transactions.sorted { $0.date > $1.date })
                } else {
                    formatter.dateFormat = "d MMMM yyyy"
                    return (formatter.string(from: date), transactions.sorted { $0.date > $1.date })
                }
            }
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    accountHeaderCard
                    
                    statisticsCard
                    
                    if sortedTransactions.isEmpty {
                        emptyTransactionsView
                    } else {
                        transactionsListView
                    }
                }
                .padding()
            }
        }
        .navigationTitle(account.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingEditAccount = true
                    } label: {
                        Label("Редактировать", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20))
                }
            }
        }
        .sheet(isPresented: $showingEditAccount) {
            AccountFormView(account: account)
        }
        .alert("Удалить счет?", isPresented: $showingDeleteAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Все транзакции этого счета также будут удалены. Это действие нельзя отменить.")
        }
    }
    
    // MARK: - Views
    
    private var accountHeaderCard: some View {
        HStack(spacing: 16) {
            // Иконка
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(account.swiftUIColor.opacity(0.2))
                    .frame(width: 70, height: 70)
                
                Image(systemName: account.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(account.swiftUIColor)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    AppText(account.name, style: .title)
                        .color(.primary)
                    
                    if account.isDefault {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.yellow)
                    }
                }
                
                AppText("Баланс счета", style: .caption)
                    .color(.secondary)
                
                AppText(account.currentBalance.formatted(.currency(code: "KZT")), style: .largeTitle)
                    .color(account.currentBalance >= 0 ? .green : .red)
            }
            
            Spacer()
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        }
    }
    
    private var statisticsCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundStyle(.green)
                        AppText("Доходы", style: .caption)
                            .color(.secondary)
                    }
                    
                    AppText(account.totalIncome.formatted(.currency(code: "KZT")), style: .section)
                        .color(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 6) {
                        AppText("Расходы", style: .caption)
                            .color(.secondary)
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundStyle(.red)
                    }
                    
                    AppText(account.totalExpenses.formatted(.currency(code: "KZT")), style: .section)
                        .color(.primary)
                }
            }
            
            Divider()
            
            HStack {
                AppText("Начальный баланс", style: .caption)
                    .color(.secondary)
                Spacer()
                AppText(account.initialBalance.formatted(.currency(code: "KZT")), style: .body)
                    .color(.primary)
            }
            
            HStack {
                AppText("Всего транзакций", style: .caption)
                    .color(.secondary)
                Spacer()
                AppText("\(account.transactions.count)", style: .body)
                    .color(.primary)
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
    }
    
    private var emptyTransactionsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            
            AppText("Нет транзакций", style: .section)
                .color(.primary)
            
            AppText("Транзакции по этому счету появятся здесь", style: .body)
                .color(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
        }
    }
    
    private var transactionsListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppText("Транзакции", style: .title)
                .color(.primary)
                .padding(.horizontal, 4)
            
            ForEach(groupedTransactions, id: \.0) { dateString, transactions in
                VStack(alignment: .leading, spacing: 8) {
                    AppText(dateString, style: .caption)
                        .color(.secondary)
                        .padding(.horizontal, 4)
                    
                    ForEach(transactions) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func deleteAccount() {
        modelContext.delete(account)
        try? modelContext.save()
    }
}

// MARK: - Transaction Row View

//struct TransactionRowView: View {
//    
//    let transaction: Transaction
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            // Иконка категории
//            if let category = transaction.category {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 10, style: .continuous)
//                        .fill(Color(category.color).opacity(0.2))
//                        .frame(width: 44, height: 44)
//                    
//                    Image(systemName: category.icon)
//                        .font(.system(size: 18))
//                        .foregroundStyle(Color(category.color))
//                }
//            } else {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 10, style: .continuous)
//                        .fill(Color.gray.opacity(0.2))
//                        .frame(width: 44, height: 44)
//                    
//                    Image(systemName: "questionmark")
//                        .font(.system(size: 18))
//                        .foregroundStyle(.gray)
//                }
//            }
//            
//            // Информация
//            VStack(alignment: .leading, spacing: 2) {
//                AppText(transaction.category?.name ?? "Без категории", style: .body)
//                    .color(.primary)
//                
//                if let note = transaction.note, !note.isEmpty {
//                    AppText(note, style: .caption)
//                        .color(.secondary)
//                }
//                
//                AppText(transaction.date.formatted(date: .omitted, time: .shortened), style: .caption)
//                    .color(.secondary)
//            }
//            
//            Spacer()
//            
//            // Сумма
//            AppText(
//                (transaction.type == .income ? "+" : "-") + transaction.amount.formatted(.currency(code: "RUB")),
//                style: .section
//            )
//            .color(transaction.type == .income ? .green : .red)
//        }
//        .padding(12)
//        .background {
//            RoundedRectangle(cornerRadius: 12, style: .continuous)
//                .fill(Color(uiColor: .systemBackground))
//                .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
//        }
//    }
//}

#Preview {
    NavigationStack {
        AccountDetailView(account: Account(name: "Основной", icon: "creditcard.fill", color: "blue", initialBalance: 10000))
    }
    .modelContainer(for: [Account.self, Transaction.self], inMemory: true)
}

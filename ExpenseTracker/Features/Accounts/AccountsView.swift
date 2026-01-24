//
//  AccountsView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI
import SwiftData

struct AccountsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Account.createdAt, order: .forward) private var accounts: [Account]
    
    @State private var showingAddAccount = false
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            if accounts.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        totalBalanceCard
                        
                        accountsList
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationTitle("Счета")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddAccount = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                }
            }
        }
        .sheet(isPresented: $showingAddAccount) {
            AccountFormView()
        }
    }
    
    // MARK: - Views
    
    private var totalBalanceCard: some View {
        let balanceData = BalanceData(accounts: accounts)
        
        return VStack(spacing: 12) {
            AppText("Общий баланс", style: .caption)
                .color(.secondary)
            
            AppText(balanceData.balance.formatted(.currency(code: "KZT")), style: .largeTitle)
                .color(.primary)
            
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    AppText("Доходы", style: .caption)
                        .color(.secondary)
                    AppText(balanceData.totalIncome.formatted(.currency(code: "KZT")), style: .section)
                        .color(.green)
                }
                
                VStack(spacing: 4) {
                    AppText("Расходы", style: .caption)
                        .color(.secondary)
                    AppText(balanceData.totalExpenses.formatted(.currency(code: "KZT")), style: .section)
                        .color(.red)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        }
    }
    
    private var accountsList: some View {
        VStack(spacing: 12) {
            ForEach(accounts) { account in
                NavigationLink {
                    AccountDetailView(account: account)
                } label: {
                    AccountCardView(account: account)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "creditcard.and.123")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            AppText("Нет счетов", style: .title)
                .color(.primary)
            
            AppText("Создайте первый счет для учета транзакций", style: .body)
                .color(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingAddAccount = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    AppText("Создать счет", style: .section)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.blue)
                }
            }
        }
        .padding()
    }
}

// MARK: - Account Card View

struct AccountCardView: View {
    
    let account: Account
    
    var body: some View {
        HStack(spacing: 16) {
            // Иконка
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(account.swiftUIColor.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                Image(systemName: account.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(account.swiftUIColor)
            }
            
            // Информация
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    AppText(account.name, style: .section)
                        .color(.primary)
                    
                    if account.isDefault {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.yellow)
                    }
                }
                
                AppText("\(account.transactions.count) транзакций", style: .caption)
                    .color(.secondary)
            }
            
            Spacer()
            
            // Баланс
            VStack(alignment: .trailing, spacing: 2) {
                AppText(account.currentBalance.formatted(.currency(code: "KZT")), style: .section)
                    .color(account.currentBalance >= 0 ? .green : .red)
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
    }
}

#Preview {
    AccountsView()
        .modelContainer(for: [Account.self, Transaction.self], inMemory: true)
}

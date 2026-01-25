//
//  AccountPickerView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI
import SwiftData

struct AccountPickerView: View {
    
    @Binding var selectedAccount: Account?
    let transactionAmount: String
    let transactionType: TransactionType
    
    @Query(sort: \Account.createdAt, order: .forward) private var accounts: [Account]
    
    @State private var showingAccountPicker = false
    
    private var amountDecimal: Decimal {
        Decimal(string: transactionAmount.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
    
    private var predictedBalance: Decimal? {
        guard let account = selectedAccount, amountDecimal > 0 else { return nil }
        
        if transactionType == .income {
            return account.currentBalance + amountDecimal
        } else {
            return account.currentBalance - amountDecimal
        }
    }
    
    var body: some View {
        Button {
            showingAccountPicker = true
        } label: {
            HStack {
                if let account = selectedAccount {
                    // Показываем выбранный счет
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(account.swiftUIColor.opacity(0.2))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: account.icon)
                                .font(.system(size: 16))
                                .foregroundStyle(account.swiftUIColor)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            AppText(account.name, style: .caption)
                                .color(.secondary)
                            
                            if let predicted = predictedBalance, amountDecimal > 0 {
                                // Показываем изменение баланса
                                Text(predicted.formatted(.currency(code: "KZT")))
                                    .font(.system(size: 15, weight: .semibold))
                                    .fontDesign(.rounded)
                                    .foregroundStyle(transactionType == .income ? .green : .red)
                            } else {
                                // Показываем текущий баланс
                                Text(account.currentBalance.formatted(.currency(code: "KZT")))
                                    .font(.system(size: 15, weight: .semibold))
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.black)
                            }
                        }
                        
                        Spacer()
                    }
                } else {
                    // Показываем плейсхолдер
                    HStack {
                        Image(systemName: "creditcard")
                            .foregroundStyle(.secondary)
                        
                        AppText("Выберите счет", style: .body)
                            .color(.secondary)
                        
                        Spacer()
                    }
                }
            }
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(uiColor: .systemBackground))
            }
        }
        .sheet(isPresented: $showingAccountPicker) {
            AccountPickerSheet(selectedAccount: $selectedAccount, accounts: accounts)
        }
        .onAppear {
            // Автоматически выбираем счет по умолчанию, если он есть
            if selectedAccount == nil {
                selectedAccount = accounts.first { $0.isDefault } ?? accounts.first
            }
        }
    }
}

// MARK: - Account Picker Sheet

struct AccountPickerSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedAccount: Account?
    let accounts: [Account]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                if accounts.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(accounts) { account in
                                Button {
                                    selectedAccount = account
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    dismiss()
                                } label: {
                                    accountRow(account)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Выбор счета")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
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
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.black)
                        }
                    }
                }
            }
        }
    }
    
    private func accountRow(_ account: Account) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(account.swiftUIColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: account.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(account.swiftUIColor)
            }
            
            HStack(spacing: 4) {
                Text(account.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)
                
                if account.isDefault {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.yellow)
                }
            }
            
            Spacer(minLength: 8)
            
            HStack(spacing: 8) {
                Text(account.currentBalance.formatted(.currency(code: "KZT")))
                    .font(.system(size: 14, weight: .semibold))
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
                
                if selectedAccount?.id == account.id {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.blue)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .cardShadow(cornerRadius: 14)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "creditcard.and.123")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            AppText("Нет счетов", style: .title)
                .color(.primary)
            
            AppText("Создайте счет в разделе \"Счета\"", style: .body)
                .color(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var selectedAccount: Account? = nil
    
    return AccountPickerView(
        selectedAccount: $selectedAccount,
        transactionAmount: "5000",
        transactionType: .expense
    )
    .padding()
    .modelContainer(for: [Account.self], inMemory: true)
}

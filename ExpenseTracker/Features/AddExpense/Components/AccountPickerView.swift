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
    @Binding var showingAccountPicker: Bool
    
    @Query(sort: \Account.createdAt, order: .forward) private var accounts: [Account]
    
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
            HStack(spacing: 10) {
                if let account = selectedAccount {
                    // Показываем выбранный счет
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(account.swiftUIColor.opacity(0.2))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: account.icon)
                            .font(.system(size: 15))
                            .foregroundStyle(account.swiftUIColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(account.name)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(.secondary)
                        
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
                                .foregroundStyle(.primary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    // Показываем плейсхолдер
                    Image(systemName: "creditcard")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 18))
                    
                    Text("Выберите счет")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 60)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(uiColor: .systemBackground))
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            // Автоматически выбираем счет по умолчанию, если он есть
            if selectedAccount == nil {
                selectedAccount = accounts.first { $0.isDefault } ?? accounts.first
            }
        }
    }
}

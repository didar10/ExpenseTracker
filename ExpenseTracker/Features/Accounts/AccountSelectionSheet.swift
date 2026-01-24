//
//  AccountSelectionSheet.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI

struct AccountSelectionSheet: View {
    
    let accounts: [Account]
    let selectedAccount: Account?
    let onSelect: (Account?) -> Void
    let onShowAll: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddAccount = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        // Все счета
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            onSelect(nil)
                        } label: {
                            allAccountsRow
                        }
                        .buttonStyle(.plain)
                        
                        // Список счетов
                        ForEach(accounts) { account in
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                onSelect(account)
                            } label: {
                                accountRow(account)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // Кнопка "Создать счет"
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            showingAddAccount = true
                        } label: {
                            createAccountButton
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                }
            }
            .navigationTitle("Выбор счета")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .bold()
                }
            }
            .sheet(isPresented: $showingAddAccount) {
                AccountFormView()
            }
        }
    }
    
    private var allAccountsRow: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                AppText("Все счета", style: .section)
                    .color(.primary)
                
                AppText("Показать транзакции по всем счетам", style: .caption)
                    .color(.secondary)
            }
            
            Spacer()
            
            if selectedAccount == nil {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.blue)
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
    }
    
    private func accountRow(_ account: Account) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(account.swiftUIColor.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                Image(systemName: account.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(account.swiftUIColor)
            }
            
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
                
                AppText(account.currentBalance.formatted(.currency(code: "KZT")), style: .caption)
                    .color(.secondary)
            }
            
            Spacer()
            
            if selectedAccount?.id == account.id {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.blue)
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
    }
    
    private var createAccountButton: some View {
        HStack {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 20))
            
            AppText("Создать счет", style: .section)
            
            Spacer()
        }
        .foregroundStyle(.blue)
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
    }
}

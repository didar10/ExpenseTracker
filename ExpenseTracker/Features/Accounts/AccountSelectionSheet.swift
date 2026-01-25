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
                    }
                    .padding()
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        showingAddAccount = true
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
                            
                            Image(systemName: "plus")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.black)
                        }
                    }
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
        .cardShadow(cornerRadius: 16)
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
}

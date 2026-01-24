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
    @Query(sort: \Account.createdAt, order: .forward) private var accounts: [Account]
    
    @State private var showingAccountPicker = false
    
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
                            AppText("Счет", style: .caption)
                                .color(.secondary)
                            AppText(account.name, style: .body)
                                .color(.primary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    // Показываем плейсхолдер
                    HStack {
                        Image(systemName: "creditcard")
                            .foregroundStyle(.secondary)
                        
                        AppText("Выберите счет", style: .body)
                            .color(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
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
                                AccountPickerRow(
                                    account: account,
                                    isSelected: selectedAccount?.id == account.id
                                ) {
                                    selectedAccount = account
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    dismiss()
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Выбор счета")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
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
            
            AppText("Создайте счет в разделе \"Счета\"", style: .body)
                .color(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Account Picker Row

struct AccountPickerRow: View {
    
    let account: Account
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Иконка
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(account.swiftUIColor.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: account.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(account.swiftUIColor)
                }
                
                // Информация
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        AppText(account.name, style: .body)
                            .color(.primary)
                        
                        if account.isDefault {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.yellow)
                        }
                    }
                    
                    AppText(account.currentBalance.formatted(.currency(code: "KZT")), style: .caption)
                        .color(.secondary)
                }
                
                Spacer()
                
                // Индикатор выбора
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.blue)
                }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(uiColor: .systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var selectedAccount: Account? = nil
    
    return AccountPickerView(selectedAccount: $selectedAccount)
        .padding()
        .modelContainer(for: [Account.self], inMemory: true)
}

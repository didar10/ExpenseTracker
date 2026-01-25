//
//  AccountPickerSheet.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI

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

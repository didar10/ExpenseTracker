//
//  AccountFilterView.swift
//  ExpenseTracker
//
//  Created by Didar on 26.01.2026.
//

import SwiftUI
import SwiftData

/// Компонент для выбора счета в статистике
struct AccountFilterView: View {
    
    @Binding var selectedAccount: Account?
    let accounts: [Account]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Кнопка "Все счета"
                FilterChipView(
                    title: "Все счета",
                    icon: "creditcard.2.fill",
                    isSelected: selectedAccount == nil,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedAccount = nil
                        }
                    }
                )
                
                // Кнопки для каждого счета
                ForEach(accounts, id: \.name) { account in
                    FilterChipView(
                        title: account.name,
                        icon: account.icon,
                        color: account.swiftUIColor,
                        isSelected: selectedAccount == account,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedAccount = account
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
    }
}

/// Чип для фильтра счетов
private struct FilterChipView: View {
    let title: String
    let icon: String
    var color: Color?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 15, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isSelected ? (color ?? .blue) : Color(uiColor: .systemBackground))
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview("С несколькими счетами") {
    @Previewable @State var selectedAccount: Account? = nil
    
    let accounts = [
        Account(name: "Наличные", icon: "banknote.fill", color: "green"),
        Account(name: "Карта", icon: "creditcard.fill", color: "blue"),
        Account(name: "Сбережения", icon: "dollarsign.circle.fill", color: "orange")
    ]
    
    VStack {
        AccountFilterView(selectedAccount: $selectedAccount, accounts: accounts)
        
        Spacer()
        
        if let account = selectedAccount {
            Text("Выбран: \(account.name)")
        } else {
            Text("Все счета")
        }
    }
}

#Preview("Без счетов") {
    @Previewable @State var selectedAccount: Account? = nil
    
    VStack {
        AccountFilterView(selectedAccount: $selectedAccount, accounts: [])
        Spacer()
    }
}

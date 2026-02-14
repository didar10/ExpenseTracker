//
//  AccountPickerButton.swift
//  ExpenseTracker
//
//  Created by Didar on 01.02.2026.
//

import SwiftUI

/// Переиспользуемая кнопка для выбора счета
struct AccountPickerButton: View {
    
    // MARK: - Properties
    
    let selectedAccount: Account?
    let totalBalance: Decimal
    let action: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            HStack(spacing: 6) {
                if let selectedAccount = selectedAccount {
                    // Выбран конкретный счет
                    accountIcon(selectedAccount)
                    accountInfo(selectedAccount)
                } else {
                    // Показываем все счета
                    allAccountsIcon
                    allAccountsInfo
                }
                
                chevronIcon
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: Color.primary.opacity(0.04), radius: 4, y: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - UI Components

private extension AccountPickerButton {
    
    /// Иконка выбранного счета
    func accountIcon(_ account: Account) -> some View {
        ZStack {
            Circle()
                .fill(account.swiftUIColor.opacity(0.2))
                .frame(width: 24, height: 24)
            
            Image(systemName: account.icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(account.swiftUIColor)
        }
    }
    
    /// Информация о выбранном счете
    func accountInfo(_ account: Account) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(account.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
            
            Text(account.currentBalance.formatted(.currency(code: "KZT")))
                .font(.system(size: 11, weight: .regular))
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
        }
    }
    
    /// Иконка для всех счетов
    var allAccountsIcon: some View {
        Image(systemName: "square.stack.3d.up.fill")
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.primary)
    }
    
    /// Информация о всех счетах
    var allAccountsInfo: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("Все счета")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
            
            Text(totalBalance.formatted(.currency(code: "KZT")))
                .font(.system(size: 11, weight: .regular))
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
        }
    }
    
    /// Иконка шеврона
    var chevronIcon: some View {
        Image(systemName: "chevron.down")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.secondary)
    }
}

// MARK: - Preview

#Preview("Selected Account") {
    let account = Account(
        name: "Основной счёт",
        icon: "creditcard.fill",
        color: "blue",
        initialBalance: 150000
    )
    
    return AccountPickerButton(
        selectedAccount: account,
        totalBalance: 150000,
        action: {}
    )
    .padding()
}

#Preview("All Accounts") {
    AccountPickerButton(
        selectedAccount: nil,
        totalBalance: 350000,
        action: {}
    )
    .padding()
}

//
//  AccountFormViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import Foundation
import SwiftData
import SwiftUI
import UIKit

@MainActor
final class AccountFormViewModel: ObservableObject {
    
    // MARK: - Input Data
    @Published var name: String = ""
    @Published var selectedIcon: String = "creditcard.fill"
    @Published var selectedColor: String = "blue"
    @Published var initialBalance: String = ""
    @Published var isDefault: Bool = false
    
    // MARK: - Private Properties
    private(set) var editingAccount: Account?
    
    // MARK: - Init
    init(account: Account? = nil) {
        self.editingAccount = account
        
        guard let account else { return }
        
        // Заполняем форму для редактирования
        name = account.name
        selectedIcon = account.icon
        selectedColor = account.color
        initialBalance = account.initialBalance == 0 ? "" : "\(account.initialBalance)"
        isDefault = account.isDefault
    }
    
    // MARK: - Computed Properties
    var isEditMode: Bool {
        editingAccount != nil
    }
    
    var isValid: Bool {
        !name.isEmpty
    }
    
    var navigationTitle: String {
        isEditMode ? "Редактировать счет" : "Новый счет"
    }
    
    var previewName: String {
        name.isEmpty ? "Название счета" : name
    }
    
    var previewNameColor: Color {
        name.isEmpty ? .secondary : .primary
    }
    
    var previewBalance: String? {
        guard let balance = balanceDecimal, balance > 0 else {
            return nil
        }
        return balance.formatted(.currency(code: "KZT"))
    }
    
    private var balanceDecimal: Decimal? {
        Decimal(string: initialBalance.replacingOccurrences(of: ",", with: "."))
    }
    
    // MARK: - Actions
    func selectIcon(_ icon: String) {
        selectedIcon = icon
        provideFeedback(.light)
    }
    
    func selectColor(_ colorName: String) {
        selectedColor = colorName
        provideFeedback(.light)
    }
    
    func save(accounts: [Account], using context: ModelContext) {
        let balance = balanceDecimal ?? 0
        
        if let account = editingAccount {
            // Редактирование существующего счета
            updateExistingAccount(account, balance: balance, accounts: accounts)
        } else {
            // Создание нового счета
            createNewAccount(balance: balance, accounts: accounts, context: context)
        }
        
        try? context.save()
    }
    
    func delete(using context: ModelContext) {
        guard let account = editingAccount else { return }
        
        // Транзакции будут удалены автоматически благодаря deleteRule: .cascade
        context.delete(account)
        try? context.save()
        
        provideFeedback(.medium)
    }
    
    // MARK: - Private Methods
    private func updateExistingAccount(_ account: Account, balance: Decimal, accounts: [Account]) {
        account.name = name
        account.icon = selectedIcon
        account.color = selectedColor
        account.initialBalance = balance
        
        // Если делаем этот счет по умолчанию, снимаем флаг с других
        if isDefault {
            for acc in accounts where acc.id != account.id {
                acc.isDefault = false
            }
        }
        account.isDefault = isDefault
    }
    
    private func createNewAccount(balance: Decimal, accounts: [Account], context: ModelContext) {
        let newAccount = Account(
            name: name,
            icon: selectedIcon,
            color: selectedColor,
            initialBalance: balance,
            isDefault: isDefault
        )
        
        // Если делаем этот счет по умолчанию, снимаем флаг с других
        if isDefault {
            for acc in accounts {
                acc.isDefault = false
            }
        }
        
        context.insert(newAccount)
    }
    
    // MARK: - Haptic Feedback
    private func provideFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

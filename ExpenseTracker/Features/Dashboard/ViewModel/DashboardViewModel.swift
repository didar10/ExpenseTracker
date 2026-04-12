//
//  DashboardViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 09.04.2026.
//

import Foundation
import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {

    // MARK: - UI State

    @Published var selectedTransaction: Transaction?
    @Published var selectedAccount: Account?
    @Published var showingAccountsView = false

    // MARK: - Computed Properties

    func filteredTransactions(from transactions: [Transaction]) -> [Transaction] {
        guard let selectedAccount else { return transactions }
        return transactions.filter { $0.account?.id == selectedAccount.id }
    }

    func balanceData(accounts: [Account], transactions: [Transaction]) -> BalanceData {
        if let selectedAccount {
            return BalanceData(accounts: [selectedAccount])
        } else if !accounts.isEmpty {
            return BalanceData(accounts: accounts)
        } else {
            return BalanceData(transactions: transactions)
        }
    }

    func groupedTransactions(from transactions: [Transaction]) -> [TransactionSection] {
        TransactionSection.group(filteredTransactions(from: transactions))
    }

    // MARK: - Actions

    func handleTransactionTap(_ transaction: Transaction) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation {
            selectedTransaction = transaction
        }
    }

    func selectAccount(_ account: Account?) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedAccount = account
        }
        showingAccountsView = false
    }

    func showAccounts() {
        showingAccountsView = true
    }

    func hideAccounts() {
        showingAccountsView = false
    }
}

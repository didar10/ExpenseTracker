//
//  AccountRepository.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation
import SwiftData

/// Поля счета из формы
struct AccountDraft: Equatable {
    var name: String
    var icon: String
    var color: String
    var initialBalance: Decimal
    var isDefault: Bool
}

extension AccountDraft {

    init(_ account: Account) {
        self.init(
            name: account.name,
            icon: account.icon,
            color: account.color,
            initialBalance: account.initialBalance,
            isDefault: account.isDefault
        )
    }

    func apply(to account: Account) {
        account.name = name
        account.icon = icon
        account.color = color
        account.initialBalance = initialBalance
        account.isDefault = isDefault
    }
}

/// Запись счетов. Правило «основной счет только один» живет здесь,
/// а не в экранах: его соблюдают и создание, и редактирование
@MainActor
protocol AccountRepository {
    @discardableResult
    func add(_ draft: AccountDraft) throws -> Account
    func update(_ account: Account, with draft: AccountDraft) throws
    /// Удаляет счет вместе с его операциями
    func delete(_ account: Account) throws
}

@MainActor
struct SwiftDataAccountRepository: AccountRepository {

    // MARK: - Properties

    let context: ModelContext

    // MARK: - Methods

    @discardableResult
    func add(_ draft: AccountDraft) throws -> Account {
        let existing = try context.fetch(FetchDescriptor<Account>())
        // Первый счет всегда становится основным: иначе новая операция открывается без счета
        let becomesDefault = draft.isDefault || existing.isEmpty

        let account = Account(
            name: draft.name,
            icon: draft.icon,
            color: draft.color,
            initialBalance: draft.initialBalance,
            isDefault: becomesDefault
        )

        if becomesDefault {
            existing.forEach { $0.isDefault = false }
        }

        context.insert(account)
        try context.saveOrRollback()
        return account
    }

    func update(_ account: Account, with draft: AccountDraft) throws {
        let previous = AccountDraft(account)
        let others = try context.fetch(FetchDescriptor<Account>())
            .filter { $0.persistentModelID != account.persistentModelID }
        let previousDefaults = others.map(\.isDefault)

        draft.apply(to: account)
        if draft.isDefault {
            others.forEach { $0.isDefault = false }
        }

        do {
            try context.saveOrRollback()
        } catch {
            // Иначе экран показывал бы правку, которой нет в базе
            previous.apply(to: account)
            zip(others, previousDefaults).forEach { $0.isDefault = $1 }
            throw error
        }
    }

    func delete(_ account: Account) throws {
        context.delete(account)
        try context.saveOrRollback()
    }
}

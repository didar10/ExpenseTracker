//
//  Repositories.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import SwiftData
import SwiftUI

/// Все репозитории приложения поверх одного контекста.
/// Экраны получают их из окружения и передают во ViewModel, тесты создают напрямую
@MainActor
struct Repositories {

    // MARK: - Properties

    let transactions: TransactionRepository
    let accounts: AccountRepository
    let categories: CategoryRepository
    let budgets: BudgetPlanRepository
    let appData: AppDataRepository

    // MARK: - Init

    init(context: ModelContext) {
        transactions = SwiftDataTransactionRepository(context: context)
        accounts = SwiftDataAccountRepository(context: context)
        categories = SwiftDataCategoryRepository(context: context)
        budgets = SwiftDataBudgetPlanRepository(context: context)
        appData = SwiftDataAppDataRepository(context: context)
    }
}

// MARK: - Environment

extension EnvironmentValues {

    /// Строится из `modelContext` окружения, поэтому работает везде,
    /// где подключен `.modelContainer`, — включая превью
    @MainActor
    var repositories: Repositories {
        Repositories(context: modelContext)
    }
}

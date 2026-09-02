//
//  CategoryListViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import Foundation
import SwiftData

/// ViewModel для списка категорий
@MainActor
@Observable
final class CategoryListViewModel {

    // MARK: - Properties

    private(set) var categoryToDelete: Category?
    /// На удаляемую категорию заведен бюджет: предупреждение должно быть строже
    private(set) var deletesBudgetPlan = false

    var showDeleteAlert = false

    // MARK: - Computed Properties

    var deleteMessage: String {
        deletesBudgetPlan ? AppString.deleteCategoryWithBudgetMessage : AppString.deleteCategoryMessage
    }

    // MARK: - Methods

    func prepareDelete(_ category: Category, context: ModelContext) {
        categoryToDelete = category
        deletesBudgetPlan = !budgetPlans(for: category, in: context).isEmpty
        showDeleteAlert = true
    }

    func cancelDelete() {
        categoryToDelete = nil
        deletesBudgetPlan = false
        showDeleteAlert = false
    }

    func confirmDelete(context: ModelContext) {
        guard let category = categoryToDelete else { return }

        // Бюджет ссылается на категорию без опционала: оставшийся план указывал бы
        // на удаленную модель, а обращение к ней роняет SwiftData
        budgetPlans(for: category, in: context).forEach { context.delete($0) }

        // У связи «операция — категория» нет обратной ссылки, поэтому SwiftData
        // не обнуляет её сам: операции остались бы с удаленной категорией
        transactions(for: category, in: context).forEach { $0.category = nil }

        context.delete(category)
        try? context.save()

        categoryToDelete = nil
        deletesBudgetPlan = false
        showDeleteAlert = false
    }

    // MARK: - Private Methods

    private func budgetPlans(for category: Category, in context: ModelContext) -> [BudgetPlan] {
        let plans = (try? context.fetch(FetchDescriptor<BudgetPlan>())) ?? []

        return plans.filter { $0.category.persistentModelID == category.persistentModelID }
    }

    private func transactions(for category: Category, in context: ModelContext) -> [Transaction] {
        let transactions = (try? context.fetch(FetchDescriptor<Transaction>())) ?? []

        return transactions.filter { $0.category?.persistentModelID == category.persistentModelID }
    }
}

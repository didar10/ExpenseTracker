//
//  CategoryListViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import Foundation
import UIKit

/// ViewModel для списка категорий
@MainActor
@Observable
final class CategoryListViewModel {

    // MARK: - Properties

    private(set) var categoryToDelete: Category?
    /// На удаляемую категорию заведен бюджет: предупреждение должно быть строже
    private(set) var deletesBudgetPlan = false

    var showDeleteAlert = false
    var showingSaveError = false

    // MARK: - Computed Properties

    var deleteMessage: String {
        deletesBudgetPlan ? AppString.deleteCategoryWithBudgetMessage : AppString.deleteCategoryMessage
    }

    // MARK: - Methods

    func prepareDelete(_ category: Category) {
        categoryToDelete = category
        deletesBudgetPlan = !category.budgetPlans.isEmpty
        showDeleteAlert = true
    }

    func cancelDelete() {
        categoryToDelete = nil
        deletesBudgetPlan = false
        showDeleteAlert = false
    }

    /// Бюджеты категории удаляются, а операции остаются без нее — по правилам связей в модели
    func confirmDelete(using repository: CategoryRepository) {
        guard let category = categoryToDelete else { return }

        do {
            try repository.delete(category)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            showingSaveError = true
        }

        categoryToDelete = nil
        deletesBudgetPlan = false
        showDeleteAlert = false
    }
}

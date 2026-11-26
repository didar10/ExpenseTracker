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

    private(set) var affectedOperationCount = 0

    var showDeleteAlert = false
    var showingSaveError = false

    // MARK: - Computed Properties

    var deleteMessage: String {
        let base = deletesBudgetPlan ? AppString.deleteCategoryWithBudgetMessage : AppString.deleteCategoryMessage
        guard affectedOperationCount > 0 else { return base }
        return base + " " + AppString.categoryAffectedOperations(affectedOperationCount)
    }

    // MARK: - Methods

    func prepareDelete(_ category: Category) {
        categoryToDelete = category
        deletesBudgetPlan = !category.budgetPlans.isEmpty
        affectedOperationCount = category.transactions.count
        showDeleteAlert = true
    }

    func cancelDelete() {
        categoryToDelete = nil
        deletesBudgetPlan = false
        affectedOperationCount = 0
        showDeleteAlert = false
    }

    /// Бюджеты категории удаляются, а операции остаются без нее — по правилам связей в модели
    @discardableResult
    func confirmDelete(using repository: CategoryRepository) -> Bool {
        guard let category = categoryToDelete else { return false }
        defer { cancelDelete() }

        do {
            try repository.delete(category)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return true
        } catch {
            showingSaveError = true
            return false
        }
    }
}

/// Totals and the drill-down use the same calendar month and transaction type.
struct CategoryMonthSummary {
    let month: Int
    let title: String
    let interval: DateInterval
    private let operations: [UUID: [Transaction]]

    init(transactions: [Transaction], type: TransactionType, now: Date, calendar: Calendar = .current) {
        month = calendar.component(.month, from: now)
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.locale = .current
        formatter.dateFormat = "LLLL"
        title = formatter.string(from: now).capitalizingFirstLetter
        interval = calendar.dateInterval(of: .month, for: now) ?? DateInterval(start: now, duration: 0)
        var grouped: [UUID: [Transaction]] = [:]
        for transaction in transactions where !transaction.isDeleted && transaction.type == type {
            guard transaction.date >= interval.start, transaction.date < interval.end,
                  let category = transaction.category, !category.isDeleted else { continue }
            grouped[category.id, default: []].append(transaction)
        }
        operations = grouped
    }

    func transactions(for id: UUID) -> [Transaction] {
        operations[id, default: []]
    }

    func caption(for id: UUID) -> String {
        let total = transactions(for: id).reduce(Decimal.zero) { $0 + $1.amount }
        let amount = total == .zero ? AppString.categoryNoMonthlyAmount : MoneyFormat.money(total)
        return AppString.spentInMonth(amount, month: month)
    }
}

/// Ordering belongs to this screen. Unknown IDs keep their alphabetical order from the query.
extension CategoryListViewModel {
    static func ordered(_ categories: [Category], by ids: [UUID]) -> [Category] {
        let byID = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })
        let known = Set(ids)
        return ids.compactMap { byID[$0] } + categories.filter { !known.contains($0.id) }
    }

    static func moved(_ source: UUID, to target: UUID, in ids: [UUID]) -> [UUID]? {
        guard source != target, let from = ids.firstIndex(of: source), let to = ids.firstIndex(of: target) else {
            return nil
        }
        var reordered = ids
        reordered.remove(at: from)
        reordered.insert(source, at: to)
        return reordered
    }
}

//
//  CategoryListViewModelTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 02.09.2026.
//

import Foundation
import SwiftData
import Testing
@testable import ExpenseTracker

@MainActor
struct CategoryListViewModelTests {

    // MARK: - Helpers

    private func makeContext() throws -> ModelContext {
        let container = try AppModelContainer.make(inMemory: true)

        return ModelContext(container)
    }

    private func makeCategory(in context: ModelContext, name: String = "Дом") -> ExpenseTracker.Category {
        let category = ExpenseTracker.Category(name: name, icon: "house.fill", colorHex: "#9C27B0")
        context.insert(category)

        return category
    }

    // MARK: - Tests

    @Test func deleteRemovesCategory() throws {
        let context = try makeContext()
        let category = makeCategory(in: context)

        let viewModel = CategoryListViewModel()
        viewModel.prepareDelete(category)
        viewModel.confirmDelete(using: Repositories(context: context).categories)

        #expect(try context.fetch(FetchDescriptor<ExpenseTracker.Category>()).isEmpty)
    }

    /// Бюджет ссылается на категорию без опционала: осиротевший план указывал бы
    /// на удаленную модель, и обращение к ней роняет SwiftData
    @Test func deleteAlsoRemovesBudgetPlanOfThatCategory() throws {
        let context = try makeContext()
        let category = makeCategory(in: context)
        let other = makeCategory(in: context, name: "Еда")

        context.insert(BudgetPlan(category: category, monthlyLimit: 50_000))
        context.insert(BudgetPlan(category: other, monthlyLimit: 30_000))

        let viewModel = CategoryListViewModel()
        viewModel.prepareDelete(category)

        #expect(viewModel.deletesBudgetPlan)
        #expect(viewModel.deleteMessage == AppString.deleteCategoryWithBudgetMessage)

        viewModel.confirmDelete(using: Repositories(context: context).categories)

        let plans = try context.fetch(FetchDescriptor<BudgetPlan>())
        #expect(plans.count == 1)
        #expect(plans.first?.category?.name == "Еда")
    }

    @Test func deleteKeepsTransactionsWithoutCategory() throws {
        let context = try makeContext()
        let category = makeCategory(in: context)
        let transaction = Transaction(amount: 1000, date: Date(), type: .expense, category: category)
        context.insert(transaction)

        let viewModel = CategoryListViewModel()
        viewModel.prepareDelete(category)
        #expect(viewModel.affectedOperationCount == 1)
        #expect(viewModel.deleteMessage.contains(AppString.categoryAffectedOperations(1)))
        viewModel.confirmDelete(using: Repositories(context: context).categories)

        let saved = try context.fetch(FetchDescriptor<Transaction>())
        #expect(saved.count == 1)
        #expect(saved.first?.category == nil)
    }

    @Test func categoryWithoutBudgetUsesPlainMessage() throws {
        let context = try makeContext()
        let category = makeCategory(in: context)

        let viewModel = CategoryListViewModel()
        viewModel.prepareDelete(category)

        #expect(!viewModel.deletesBudgetPlan)
        #expect(viewModel.deleteMessage == AppString.deleteCategoryMessage)
    }

    @Test func orderingKeepsNewCategoriesAndIgnoresDeletedIDs() throws {
        let context = try makeContext()
        let first = makeCategory(in: context, name: "Дом")
        let second = makeCategory(in: context, name: "Еда")
        let added = makeCategory(in: context, name: "Кафе")
        let moved = try #require(CategoryListViewModel.moved(first.id, to: second.id, in: [first.id, second.id]))
        let sorted = CategoryListViewModel.ordered([first, second, added], by: [UUID()] + moved)
        #expect(sorted.map(\.id) == [second.id, first.id, added.id])
    }

    @Test func monthlySummaryUsesCalendarBoundariesAndOperationType() throws {
        let context = try makeContext()
        let category = makeCategory(in: context)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let now = try #require(calendar.date(from: DateComponents(year: 2026, month: 11, day: 20)))
        let month = try #require(calendar.dateInterval(of: .month, for: now))
        let current = Transaction(amount: 20_650, date: month.start, type: .expense, category: category)
        let previous = Transaction(amount: 900, date: month.start.addingTimeInterval(-1), type: .expense, category: category)
        let next = Transaction(amount: 800, date: month.end, type: .expense, category: category)
        let income = Transaction(amount: 700, date: now, type: .income, category: category)
        let summary = CategoryMonthSummary(transactions: [current, previous, next, income], type: .expense, now: now, calendar: calendar)
        #expect(summary.transactions(for: category.id).map(\.amount) == [20_650])
        #expect(summary.caption(for: category.id) == AppString.spentInMonth(MoneyFormat.money(20_650), month: 11))
    }

    @Test func cancelClearsPendingDelete() throws {
        let context = try makeContext()
        let category = makeCategory(in: context)

        let viewModel = CategoryListViewModel()
        viewModel.prepareDelete(category)
        viewModel.cancelDelete()

        #expect(!viewModel.showDeleteAlert)
        #expect(viewModel.categoryToDelete == nil)

        viewModel.confirmDelete(using: Repositories(context: context).categories)

        #expect(try context.fetch(FetchDescriptor<ExpenseTracker.Category>()).count == 1)
    }
}

@MainActor
struct AddEditCategoryViewModelTests {

    private func makeContext() throws -> ModelContext {
        let container = try AppModelContainer.make(inMemory: true)

        return ModelContext(container)
    }

    @Test func untouchedFormHasNoUnsavedChanges() {
        let viewModel = AddEditCategoryViewModel()

        #expect(!viewModel.hasUnsavedChanges)
    }

    @Test func editedFieldMarksFormAsChanged() {
        let category = ExpenseTracker.Category(name: "Еда", icon: "fork.knife", colorHex: "#34C759")
        let viewModel = AddEditCategoryViewModel(category: category)

        #expect(!viewModel.hasUnsavedChanges)

        viewModel.formData.name = "Кафе"

        #expect(viewModel.hasUnsavedChanges)
    }

    @Test func nameOfSpacesIsNotSaved() throws {
        let context = try makeContext()
        let viewModel = AddEditCategoryViewModel()
        viewModel.formData.name = "   "

        #expect(!viewModel.save(using: Repositories(context: context).categories))
        #expect(try context.fetch(FetchDescriptor<ExpenseTracker.Category>()).isEmpty)
    }

    @Test func duplicateNameIsRejectedAcrossTypesIgnoringCaseAndWhitespace() throws {
        let context = try makeContext()
        let existing = ExpenseTracker.Category(name: "Кафе", icon: "cup.and.saucer", colorHex: "#8EE3A1")
        context.insert(existing)
        try context.save()

        let viewModel = AddEditCategoryViewModel(initialType: .income)
        viewModel.formData.name = "  кАфЕ "
        #expect(viewModel.nameError(in: [existing]) == .duplicate)
        #expect(!viewModel.save(using: Repositories(context: context).categories))
        #expect(try context.fetchCount(FetchDescriptor<ExpenseTracker.Category>()) == 1)
    }

    @Test func editingAcceptsOwnNameAndDoesNotChangeType() throws {
        let context = try makeContext()
        let category = ExpenseTracker.Category(name: "Кафе", icon: "cup.and.saucer", colorHex: "#8EE3A1")
        context.insert(category)
        try context.save()

        let viewModel = AddEditCategoryViewModel(category: category)
        viewModel.formData.type = .income
        #expect(viewModel.nameError(in: [category]) == nil)
        #expect(viewModel.save(using: Repositories(context: context).categories))
        #expect(category.type == .expense)
    }

    @Test func savedNameIsTrimmed() throws {
        let context = try makeContext()
        let viewModel = AddEditCategoryViewModel()
        viewModel.formData.name = "  Кафе  "

        #expect(viewModel.save(using: Repositories(context: context).categories))
        #expect(try context.fetch(FetchDescriptor<ExpenseTracker.Category>()).first?.name == "Кафе")
    }
}

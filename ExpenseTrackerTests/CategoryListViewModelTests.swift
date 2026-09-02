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
        let container = try ModelContainer(
            for: Transaction.self, ExpenseTracker.Category.self, Account.self, BudgetPlan.self,
            // Имя у конфигурации своё: безымянное in-memory хранилище общее
            // для всех контейнеров процесса, и параллельные тесты видят чужие данные
            configurations: ModelConfiguration(UUID().uuidString, isStoredInMemoryOnly: true)
        )

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
        viewModel.prepareDelete(category, context: context)
        viewModel.confirmDelete(context: context)

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
        viewModel.prepareDelete(category, context: context)

        #expect(viewModel.deletesBudgetPlan)
        #expect(viewModel.deleteMessage == AppString.deleteCategoryWithBudgetMessage)

        viewModel.confirmDelete(context: context)

        let plans = try context.fetch(FetchDescriptor<BudgetPlan>())
        #expect(plans.count == 1)
        #expect(plans.first?.category.name == "Еда")
    }

    @Test func deleteKeepsTransactionsWithoutCategory() throws {
        let context = try makeContext()
        let category = makeCategory(in: context)
        let transaction = Transaction(amount: 1000, date: Date(), type: .expense, category: category)
        context.insert(transaction)

        let viewModel = CategoryListViewModel()
        viewModel.prepareDelete(category, context: context)
        viewModel.confirmDelete(context: context)

        let saved = try context.fetch(FetchDescriptor<Transaction>())
        #expect(saved.count == 1)
        #expect(saved.first?.category == nil)
    }

    @Test func categoryWithoutBudgetUsesPlainMessage() throws {
        let context = try makeContext()
        let category = makeCategory(in: context)

        let viewModel = CategoryListViewModel()
        viewModel.prepareDelete(category, context: context)

        #expect(!viewModel.deletesBudgetPlan)
        #expect(viewModel.deleteMessage == AppString.deleteCategoryMessage)
    }

    @Test func cancelClearsPendingDelete() throws {
        let context = try makeContext()
        let category = makeCategory(in: context)

        let viewModel = CategoryListViewModel()
        viewModel.prepareDelete(category, context: context)
        viewModel.cancelDelete()

        #expect(!viewModel.showDeleteAlert)
        #expect(viewModel.categoryToDelete == nil)

        viewModel.confirmDelete(context: context)

        #expect(try context.fetch(FetchDescriptor<ExpenseTracker.Category>()).count == 1)
    }
}

@MainActor
struct AddEditCategoryViewModelTests {

    private func makeContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: Transaction.self, ExpenseTracker.Category.self, Account.self, BudgetPlan.self,
            // Имя у конфигурации своё: безымянное in-memory хранилище общее
            // для всех контейнеров процесса, и параллельные тесты видят чужие данные
            configurations: ModelConfiguration(UUID().uuidString, isStoredInMemoryOnly: true)
        )

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

        #expect(!viewModel.save(context: context))
        #expect(try context.fetch(FetchDescriptor<ExpenseTracker.Category>()).isEmpty)
    }

    @Test func savedNameIsTrimmed() throws {
        let context = try makeContext()
        let viewModel = AddEditCategoryViewModel()
        viewModel.formData.name = "  Кафе  "

        #expect(viewModel.save(context: context))
        #expect(try context.fetch(FetchDescriptor<ExpenseTracker.Category>()).first?.name == "Кафе")
    }
}

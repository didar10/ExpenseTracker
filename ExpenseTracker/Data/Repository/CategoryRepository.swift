//
//  CategoryRepository.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation
import SwiftData

/// Поля категории из формы
struct CategoryDraft: Equatable {
    var name: String
    var icon: String
    var colorHex: String
    var type: TransactionType
}

extension CategoryDraft {

    init(_ category: Category) {
        self.init(name: category.name, icon: category.icon, colorHex: category.colorHex, type: category.type)
    }

    func apply(to category: Category) {
        category.name = name
        category.icon = icon
        category.colorHex = colorHex
        category.type = type
    }
}

/// Запись категорий
@MainActor
protocol CategoryRepository {
    @discardableResult
    func add(_ draft: CategoryDraft) throws -> Category
    func update(_ category: Category, with draft: CategoryDraft) throws
    /// Операции категории остаются без нее, бюджеты удаляются — по правилам связей в модели
    func delete(_ category: Category) throws
}

@MainActor
struct SwiftDataCategoryRepository: CategoryRepository {

    // MARK: - Properties

    let context: ModelContext

    // MARK: - Methods

    @discardableResult
    func add(_ draft: CategoryDraft) throws -> Category {
        let category = Category(name: draft.name, icon: draft.icon, colorHex: draft.colorHex, type: draft.type)
        context.insert(category)
        try context.saveOrRollback()
        return category
    }

    func update(_ category: Category, with draft: CategoryDraft) throws {
        let previous = CategoryDraft(category)
        draft.apply(to: category)

        do {
            try context.saveOrRollback()
        } catch {
            // Иначе экран показывал бы правку, которой нет в базе
            previous.apply(to: category)
            throw error
        }
    }

    func delete(_ category: Category) throws {
        context.delete(category)
        try context.saveOrRollback()
    }
}

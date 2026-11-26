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

enum CategoryNameError: Error {
    case empty
    case duplicate

    static func validate(_ name: String, excluding id: UUID?, in categories: [Category]) -> Self? {
        let candidate = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !candidate.isEmpty else { return .empty }
        let conflict = categories.contains { category in
            !category.isDeleted && category.id != id &&
            category.name.trimmingCharacters(in: .whitespacesAndNewlines).caseInsensitiveCompare(candidate) == .orderedSame
        }
        return conflict ? .duplicate : nil
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
        try validateName(draft.name)
        let category = Category(name: draft.name, icon: draft.icon, colorHex: draft.colorHex, type: draft.type)
        context.insert(category)
        try context.saveOrRollback()
        return category
    }

    func update(_ category: Category, with draft: CategoryDraft) throws {
        try validateName(draft.name, excluding: category.id)
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

    private func validateName(_ name: String, excluding id: UUID? = nil) throws {
        let categories = try context.fetch(FetchDescriptor<Category>())
        if let error = CategoryNameError.validate(name, excluding: id, in: categories) { throw error }
    }

    func delete(_ category: Category) throws {
        context.delete(category)
        try context.saveOrRollback()
    }
}

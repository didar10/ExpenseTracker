//
//  AddEditCategoryViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class AddEditCategoryViewModel {

    // MARK: - Properties

    var formData: CategoryFormData
    var showingSaveError = false
    private(set) var saveNameError: CategoryNameError?
    let category: Category?
    private let categoryID: UUID?


    /// Состояние формы на момент открытия: по нему определяется, есть ли несохраненные правки
    private let initialFormData: CategoryFormData

    // MARK: - Computed Properties

    var isEditMode: Bool {
        category != nil
    }

    func nameError(in categories: [Category]) -> CategoryNameError? {
        CategoryNameError.validate(formData.name, excluding: categoryID, in: categories) ?? saveNameError
    }

    func clearSaveNameError() {
        saveNameError = nil
    }

    var originalIcon: String? { isEditMode ? initialFormData.icon : nil }

    var title: String {
        isEditMode ? AppString.editCategory : AppString.newCategory
    }

    var saveButtonTitle: String {
        isEditMode ? AppString.save : AppString.createCategory
    }

    /// Закрытие формы с правками проходит через подтверждение
    var hasUnsavedChanges: Bool {
        formData != initialFormData
    }

    // MARK: - Init

    init(category: Category? = nil, initialType: TransactionType = .expense) {
        self.category = category
        categoryID = category?.id

        let formData = category.map(CategoryFormData.init(from:)) ?? CategoryFormData(type: initialType)

        self.formData = formData
        self.initialFormData = formData
    }

    // MARK: - Actions

    /// - Returns: false — форма невалидна или запись не удалась; экран остается открытым
    func save(using repository: CategoryRepository) -> Bool {
        guard !formData.trimmedName.isEmpty else { return false }

        let draft = CategoryDraft(
            name: formData.trimmedName,
            icon: formData.icon,
            colorHex: formData.colorHex,
            type: isEditMode ? initialFormData.type : formData.type
        )

        do {
            if let category {
                try repository.update(category, with: draft)
            } else {
                try repository.add(draft)
            }
            return true
        } catch let error as CategoryNameError {
            saveNameError = error
            return false
        } catch {
            showingSaveError = true
            return false
        }
    }
}

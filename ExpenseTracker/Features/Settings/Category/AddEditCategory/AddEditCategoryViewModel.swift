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

    private let category: Category?

    /// Состояние формы на момент открытия: по нему определяется, есть ли несохраненные правки
    private let initialFormData: CategoryFormData

    // MARK: - Computed Properties

    var isEditMode: Bool {
        category != nil
    }

    var canSave: Bool {
        formData.isValid
    }

    var title: String {
        isEditMode ? AppString.editCategory : AppString.newCategory
    }

    var saveButtonTitle: String {
        if !canSave {
            return AppString.enterName
        }
        return isEditMode ? AppString.saveChanges : AppString.createCategory
    }

    /// Закрытие формы с правками проходит через подтверждение
    var hasUnsavedChanges: Bool {
        formData != initialFormData
    }

    // MARK: - Init

    init(category: Category? = nil) {
        self.category = category

        let formData = category.map(CategoryFormData.init(from:)) ?? CategoryFormData()

        self.formData = formData
        self.initialFormData = formData
    }

    // MARK: - Actions

    func save(context: ModelContext) -> Bool {
        guard canSave else { return false }

        if let category {
            category.name = formData.trimmedName
            category.icon = formData.icon
            category.colorHex = formData.colorHex
            category.type = formData.type
        } else {
            let newCategory = Category(
                name: formData.trimmedName,
                icon: formData.icon,
                colorHex: formData.colorHex,
                type: formData.type
            )
            context.insert(newCategory)
        }

        try? context.save()
        return true
    }
}

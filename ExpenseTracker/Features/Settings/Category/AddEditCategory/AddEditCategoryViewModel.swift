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

    /// - Returns: false — форма невалидна или запись не удалась; экран остается открытым
    func save(using repository: CategoryRepository) -> Bool {
        guard canSave else { return false }

        let draft = CategoryDraft(
            name: formData.trimmedName,
            icon: formData.icon,
            colorHex: formData.colorHex,
            type: formData.type
        )

        do {
            if let category {
                try repository.update(category, with: draft)
            } else {
                try repository.add(draft)
            }
            return true
        } catch {
            showingSaveError = true
            return false
        }
    }
}

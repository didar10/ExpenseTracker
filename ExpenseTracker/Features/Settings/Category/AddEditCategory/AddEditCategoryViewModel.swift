//
//  AddEditCategoryViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
final class AddEditCategoryViewModel {

    // MARK: - Properties

    var formData: CategoryFormData
    var showIconPicker = false

    private let category: Category?

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
        isEditMode ? AppString.saveChanges : AppString.createCategory
    }

    // MARK: - Init

    init(category: Category? = nil) {
        self.category = category

        if let category {
            self.formData = CategoryFormData(from: category)
        } else {
            self.formData = CategoryFormData()
        }
    }

    // MARK: - Actions

    func toggleIconPicker() {
        showIconPicker.toggle()
    }

    func save(context: ModelContext) -> Bool {
        guard canSave else { return false }

        if let category {
            category.name = formData.trimmedName
            category.icon = formData.icon
            category.colorHex = formData.colorHex
        } else {
            let newCategory = Category(
                name: formData.trimmedName,
                icon: formData.icon,
                colorHex: formData.colorHex
            )
            context.insert(newCategory)
        }

        try? context.save()
        return true
    }
}

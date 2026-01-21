//
//  CategoryListViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import Foundation
import SwiftData

/// ViewModel для списка категорий
@Observable
final class CategoryListViewModel {
    
    // MARK: - Properties
    
    private(set) var categoryToDelete: Category?
    var showDeleteAlert = false
    
    // MARK: - Methods
    
    func prepareDelete(_ category: Category) {
        categoryToDelete = category
        showDeleteAlert = true
    }
    
    func cancelDelete() {
        categoryToDelete = nil
        showDeleteAlert = false
    }
    
    func confirmDelete(context: ModelContext) {
        guard let category = categoryToDelete else { return }
        
        context.delete(category)
        try? context.save()
        
        categoryToDelete = nil
        showDeleteAlert = false
    }
}

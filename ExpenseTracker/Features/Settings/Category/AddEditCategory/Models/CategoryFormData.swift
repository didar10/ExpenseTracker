//
//  CategoryFormData.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import Foundation

/// Модель данных формы категории
struct CategoryFormData {
    var name: String
    var icon: String
    var colorHex: String
    
    init(
        name: String = "",
        icon: String = "cart.fill",
        colorHex: String = "#34C759"
    ) {
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
    }
    
    init(from category: Category) {
        self.name = category.name
        self.icon = category.icon
        self.colorHex = category.colorHex
    }
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }
}

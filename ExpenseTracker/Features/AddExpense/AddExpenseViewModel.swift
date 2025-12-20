//
//  AddExpenseViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI
import SwiftData

@MainActor
final class AddExpenseViewModel: ObservableObject {

    @Published var amount: String = ""
    @Published var selectedCategory: Category?
    @Published var note: String = ""
    @Published var date: Date = .now

    func save(using context: ModelContext) {
        guard
            let value = Decimal(string: amount),
            let category = selectedCategory
        else { return }

        let expense = Expense(
            amount: value,
            date: date,
            note: note.isEmpty ? nil : note,
            category: category
        )

        context.insert(expense)

        do {
            try context.save()
            print("✅ Expense saved")
        } catch {
            print("❌ Failed to save expense:", error)
        }
    }

    var isSaveEnabled: Bool {
        Decimal(string: amount) != nil && selectedCategory != nil
    }
}

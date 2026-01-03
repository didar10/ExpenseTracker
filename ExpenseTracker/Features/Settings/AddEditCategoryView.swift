//
//  AddEditCategoryView.swift
//  ExpenseTracker
//
//  Created by Didar on 03.01.2026.
//

import SwiftUI
import SwiftData

struct AddEditCategoryView: View {

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let category: Category?

    @State private var name: String
    @State private var icon: String
    @State private var colorHex: String

    init(category: Category? = nil) {
        self.category = category
        _name = State(initialValue: category?.name ?? "")
        _icon = State(initialValue: category?.icon ?? "cart")
        _colorHex = State(initialValue: category?.colorHex ?? "#34C759")
    }

    var body: some View {
        Form {
            Section("Название") {
                TextField("Категория", text: $name)
            }

            Section("Иконка") {
                IconPicker(selectedIcon: $icon)
            }

            Section("Цвет") {
                ColorPicker(
                    "Цвет",
                    selection: Binding(
                        get: { Color(hex: colorHex) },
                        set: { colorHex = $0.toHex() }
                    )
                )
            }
        }
        .navigationTitle(category == nil ? "Новая категория" : "Редактировать")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить", action: save)
                    .disabled(name.isEmpty)
            }
        }
    }

    private func save() {
        if let category {
            category.name = name
            category.icon = icon
            category.colorHex = colorHex
        } else {
            let newCategory = Category(
                name: name,
                icon: icon,
                colorHex: colorHex
            )
            context.insert(newCategory)
        }

        try? context.save()
        dismiss()
    }
}


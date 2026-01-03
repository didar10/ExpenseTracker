//
//  CategoriesListView.swift
//  ExpenseTracker
//
//  Created by Didar on 03.01.2026.
//

import SwiftUI
import SwiftData

struct CategoriesListView: View {

    @Query(sort: \Category.name)
    private var categories: [Category]

    @Environment(\.modelContext) private var context
    @State private var isAddPresented = false

    var body: some View {
        List {
            ForEach(categories) { category in
                NavigationLink {
                    AddEditCategoryView(category: category)
                } label: {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundColor(Color(hex: category.colorHex))
                            .frame(width: 28)

                        Text(category.name)
                    }
                }
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Категории")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isAddPresented = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isAddPresented) {
            NavigationStack {
                AddEditCategoryView()
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { categories[$0] }.forEach(context.delete)
        try? context.save()
    }
}


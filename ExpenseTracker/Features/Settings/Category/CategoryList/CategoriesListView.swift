//
//  CategoriesListView.swift
//  ExpenseTracker
//
//  Created by Didar on 03.01.2026.
//

import SwiftUI
import SwiftData

struct CategoriesListView: View {
    
    // MARK: - Properties
    
    @Query(sort: \Category.name)
    private var categories: [Category]
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabBarVisibility) private var isTabBarVisible
    
    @State private var viewModel = CategoryListViewModel()
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    if categories.isEmpty {
                        EmptyCategoriesView()
                    } else {
                        categoriesList
                    }
                }
                .padding()
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Категории")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    isTabBarVisible.wrappedValue = true
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.green)
                        .symbolRenderingMode(.hierarchical)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    AddEditCategoryView()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.green)
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
        .onAppear {
            isTabBarVisible.wrappedValue = false
        }
        .alert("Удалить категорию?", isPresented: $viewModel.showDeleteAlert) {
            Button("Отмена", role: .cancel) {
                viewModel.cancelDelete()
            }
            Button("Удалить", role: .destructive) {
                viewModel.confirmDelete(context: context)
            }
        } message: {
            Text("Это действие нельзя отменить")
        }
    }
    
    // MARK: - UI Components
    
    private var categoriesList: some View {
        CategoriesCardView {
            VStack(spacing: 0) {
                ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                    NavigationLink {
                        AddEditCategoryView(category: category)
                    } label: {
                        CategoryRowView(
                            category: category,
                            onDelete: {
                                viewModel.prepareDelete(category)
                            }
                        )
                    }
                    .buttonStyle(.plain)
                    
                    if index < categories.count - 1 {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CategoriesListView()
    }
}



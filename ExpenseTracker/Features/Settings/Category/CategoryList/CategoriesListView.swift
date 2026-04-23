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
            AppColor.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    if categories.isEmpty {
                        EmptyCategoriesView()
                    } else {
                        categoriesList
                    }
                }
                .padding(AppSpacing.large)
                .padding(.bottom, AppSpacing.tabBarBottomInset)
            }
        }
        .navigationTitle(AppString.categories)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                ToolbarIconButton(icon: "chevron.left") {
                    isTabBarVisible.wrappedValue = true
                    dismiss()
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    AddEditCategoryView()
                } label: {
                    ToolbarIconButtonLabel(icon: "plus")
                }
            }
        }
        .onAppear {
            isTabBarVisible.wrappedValue = false
        }
        .alert(AppString.deleteCategoryConfirm, isPresented: $viewModel.showDeleteAlert) {
            Button(AppString.cancel, role: .cancel) {
                viewModel.cancelDelete()
            }
            Button(AppString.delete, role: .destructive) {
                viewModel.confirmDelete(context: context)
            }
        } message: {
            Text(AppString.cannotUndo)
        }
    }
}

// MARK: - Subviews
private extension CategoriesListView {

    var categoriesList: some View {
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
                            .padding(.leading, AppSpacing.listDividerIndent)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CategoriesListView()
    }
}

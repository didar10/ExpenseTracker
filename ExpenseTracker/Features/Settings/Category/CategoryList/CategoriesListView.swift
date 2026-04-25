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
    @State private var isEditing = false

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

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

            if !isEditing {
                NavigationLink {
                    AddEditCategoryView()
                } label: {
                    CategoryAddFloatingButton()
                }
                .padding(.trailing, AppSpacing.large)
                .padding(.bottom, AppSpacing.xxxLarge)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
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

    var header: some View {
        ZStack {
            AppText(AppString.categories, style: .section)

            HStack {
                ToolbarIconButton(icon: "chevron.left", isOutlined: true) {
                    isTabBarVisible.wrappedValue = true
                    dismiss()
                }

                Spacer()

                if !categories.isEmpty {
                    CategoryEditToggleButton(isEditing: isEditing) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditing.toggle()
                        }
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.small)
    }

    var categoriesList: some View {
        CategoriesCardView {
            VStack(spacing: 0) {
                ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                    rowContent(for: category)

                    if index < categories.count - 1 {
                        Divider()
                            .padding(.leading, AppSpacing.listDividerIndent)
                    }
                }
            }
        }
    }

    @ViewBuilder
    func rowContent(for category: Category) -> some View {
        if isEditing {
            CategoryRowView(
                category: category,
                isEditing: true,
                onDelete: {
                    viewModel.prepareDelete(category)
                }
            )
        } else {
            NavigationLink {
                AddEditCategoryView(category: category)
            } label: {
                CategoryRowView(
                    category: category,
                    isEditing: false,
                    onDelete: {
                        viewModel.prepareDelete(category)
                    }
                )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    NavigationStack {
        CategoriesListView()
    }
}

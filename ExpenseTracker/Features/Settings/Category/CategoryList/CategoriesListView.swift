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

    /// Когда задан — экран работает в режиме выбора: тап по категории выбирает её, а не открывает редактирование.
    var onSelect: ((Category) -> Void)? = nil
    var initialType: TransactionType = .expense

    @Query(sort: \Category.name)
    private var categories: [Category]

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = CategoryListViewModel()
    @State private var isEditing = false
    @State private var showingAddCategory = false
    @State private var editingCategory: Category?
    @State private var selectedType: TransactionType = .expense

    // MARK: - Computed Properties

    private var filteredCategories: [Category] {
        categories.filter { $0.type == selectedType }
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: AppSpacing.large) {
                        TransactionTypePickerView(selectedType: $selectedType)

                        if filteredCategories.isEmpty {
                            EmptyCategoriesView()
                        } else {
                            categoriesList
                        }
                    }
                    .padding(AppSpacing.large)
                    .padding(.bottom, AppSpacing.xxxLarge)
                }
            }

            if !isEditing {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showingAddCategory = true
                } label: {
                    CategoryAddFloatingButton()
                }
                .padding(.trailing, AppSpacing.large)
                .padding(.bottom, AppSpacing.xxxLarge)
            }
        }
        .onAppear {
            selectedType = initialType
        }
        .onChange(of: selectedType) {
            isEditing = false
        }
        .sheet(isPresented: $showingAddCategory) {
            AddEditCategoryView()
        }
        .sheet(item: $editingCategory) { category in
            AddEditCategoryView(category: category)
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
            AppText(AppString.categories, style: .bodySmall)

            HStack {
                ToolbarIconButton(icon: "xmark", isOutlined: true) {
                    dismiss()
                }

                Spacer()

                if !filteredCategories.isEmpty {
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
        .padding(.top, AppSpacing.medium)
    }

    var categoriesList: some View {
        CategoriesCardView {
            VStack(spacing: 0) {
                ForEach(Array(filteredCategories.enumerated()), id: \.element.id) { index, category in
                    rowContent(for: category)

                    if index < filteredCategories.count - 1 {
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
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                if let onSelect {
                    onSelect(category)
                    dismiss()
                } else {
                    editingCategory = category
                }
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

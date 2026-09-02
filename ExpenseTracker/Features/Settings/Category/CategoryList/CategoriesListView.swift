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
    /// Когда задан — в списке доступны только эти категории (например, свободные для нового бюджета).
    var selectableCategoryIDs: Set<PersistentIdentifier>? = nil

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
        categories.filter { category in
            guard category.type == selectedType else { return false }
            guard let selectableCategoryIDs else { return true }
            return selectableCategoryIDs.contains(category.persistentModelID)
        }
    }

    /// Категории этого типа есть, но все заняты фильтром выбора — например,
    /// на каждую из них уже заведен бюджет
    private var isFilteredOutByPicker: Bool {
        selectableCategoryIDs != nil && categories.contains { $0.type == selectedType }
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                content
            }

            if !isEditing {
                AddFloatingButton(title: AppString.addNew) {
                    showingAddCategory = true
                }
                .padding(.trailing, AppSpacing.large)
                .padding(.bottom, AppSpacing.xxxLarge)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .onAppear {
            selectedType = initialType
        }
        .onChange(of: selectedType) {
            isEditing = false
        }
        // Список опустел — редактировать больше нечего
        .onChange(of: filteredCategories.isEmpty) { _, isEmpty in
            if isEmpty {
                isEditing = false
            }
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
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        } message: {
            Text(viewModel.deleteMessage)
        }
    }
}

// MARK: - Subviews
private extension CategoriesListView {

    var header: some View {
        SheetHeaderView(title: AppString.categories) {
            dismiss()
        } trailing: {
            // В режиме выбора категории не редактируются: это чужой экран, открытый ради выбора
            if onSelect == nil && !filteredCategories.isEmpty {
                EditToggleButton(isEditing: isEditing) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditing.toggle()
                    }
                }
                .accessibilityLabel(isEditing ? AppString.done : AppString.edit)
            }
        }
    }

    var content: some View {
        ScrollView {
            VStack(spacing: AppSpacing.large) {
                TransactionTypePickerView(selectedType: $selectedType)

                if filteredCategories.isEmpty {
                    emptyState
                } else {
                    categoriesList
                }
            }
            .padding(AppSpacing.large)
            // Плавающая кнопка не должна перекрывать последнюю строку списка
            .padding(.bottom, AppSpacing.huge + AppSpacing.xxxLarge)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    @ViewBuilder
    var emptyState: some View {
        if isFilteredOutByPicker {
            EmptyCategoriesView(
                title: AppString.allCategoriesUsed,
                hint: AppString.allCategoriesUsedHint
            ) {
                showingAddCategory = true
            }
        } else {
            EmptyCategoriesView {
                showingAddCategory = true
            }
        }
    }

    var categoriesList: some View {
        // Отступы совпадают со строкой списка счетов: одинаковые карточки на всех экранах
        VStack(spacing: 0) {
            ForEach(Array(filteredCategories.enumerated()), id: \.element.id) { index, category in
                rowContent(for: category)

                if index < filteredCategories.count - 1 {
                    Divider()
                        .padding(.leading, AppSize.iconLarge + AppSpacing.medium)
                }
            }
        }
        .padding(.vertical, AppSpacing.small)
        .padding(.horizontal, AppSpacing.large)
        .card(cornerRadius: AppRadius.xLarge)
    }

    @ViewBuilder
    func rowContent(for category: Category) -> some View {
        if isEditing {
            CategoryRowView(category: category, isEditing: true) {
                viewModel.prepareDelete(category, context: context)
            }
        } else {
            Button {
                handleTap(on: category)
            } label: {
                CategoryRowView(category: category, isEditing: false, onDelete: {})
            }
            .buttonStyle(HighlightRowButtonStyle(cornerRadius: AppRadius.medium))
        }
    }
}

// MARK: - Actions
private extension CategoriesListView {

    func handleTap(on category: Category) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        guard let onSelect else {
            editingCategory = category
            return
        }

        onSelect(category)
        dismiss()
    }
}

#Preview {
    CategoriesListView()
        .modelContainer(for: [Category.self], inMemory: true)
}

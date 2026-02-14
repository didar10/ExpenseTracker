//
//  AddEditCategoryView.swift
//  ExpenseTracker
//
//  Created by Didar on 03.01.2026.
//

import SwiftUI
import SwiftData

struct AddEditCategoryView: View {
    
    // MARK: - Properties
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabBarVisibility) private var isTabBarVisible
    
    @State private var viewModel: AddEditCategoryViewModel
    
    // MARK: - Initialization
    
    init(category: Category? = nil) {
        _viewModel = State(initialValue: AddEditCategoryViewModel(category: category))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    CategoryPreviewCardView(
                        name: viewModel.formData.name,
                        icon: viewModel.formData.icon,
                        colorHex: viewModel.formData.colorHex
                    )
                    
                    nameSection
                    
                    iconSection
                    
                    colorSection
                    
                    CategorySaveButtonView(
                        title: viewModel.saveButtonTitle,
                        isEnabled: viewModel.canSave,
                        action: handleSave
                    )
                }
                .padding()
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(viewModel.title)
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
        }
        .onAppear {
            isTabBarVisible.wrappedValue = false
        }
        .sheet(isPresented: $viewModel.showIconPicker) {
            NavigationStack {
                IconPickerSheet(selectedIcon: $viewModel.formData.icon)
            }
        }
    }
    
    // MARK: - UI Sections
    
    private var nameSection: some View {
        CategoryFormSectionView(title: "Название") {
            TextField("Введите название", text: $viewModel.formData.name)
                .font(.system(size: 17))
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(uiColor: .systemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                )
        }
    }
    
    private var iconSection: some View {
        CategoryFormSectionView(title: "Иконка") {
            CategoryIconPickerButtonView(
                icon: viewModel.formData.icon,
                colorHex: viewModel.formData.colorHex,
                action: viewModel.toggleIconPicker
            )
        }
    }
    
    private var colorSection: some View {
        CategoryFormSectionView(title: "Цвет") {
            CategoryColorPickerView(colorHex: $viewModel.formData.colorHex)
        }
    }
    
    // MARK: - Actions
    
    private func handleSave() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        withAnimation {
            if viewModel.save(context: context) {
                isTabBarVisible.wrappedValue = true
                dismiss()
            }
        }
    }
}

// MARK: - Preview

#Preview("New Category") {
    NavigationStack {
        AddEditCategoryView()
    }
}

#Preview("Edit Category") {
    NavigationStack {
        AddEditCategoryView(
            category: Category(
                name: "Продукты",
                icon: "cart.fill",
                colorHex: "#FF6B6B"
            )
        )
    }
}


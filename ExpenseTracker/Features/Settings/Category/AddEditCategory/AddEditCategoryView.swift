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

    // MARK: - Init

    init(category: Category? = nil) {
        _viewModel = State(initialValue: AddEditCategoryViewModel(category: category))
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColor.background
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
}

// MARK: - Subviews
private extension AddEditCategoryView {

    var nameSection: some View {
        CategoryFormSectionView(title: AppString.name) {
            TextField(AppString.enterName, text: $viewModel.formData.name)
                .font(.app(.body))
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColor.cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(AppColor.textPrimary.opacity(0.08), lineWidth: 1)
                )
        }
    }

    var iconSection: some View {
        CategoryFormSectionView(title: AppString.icon) {
            CategoryIconPickerButtonView(
                icon: viewModel.formData.icon,
                colorHex: viewModel.formData.colorHex,
                action: viewModel.toggleIconPicker
            )
        }
    }

    var colorSection: some View {
        CategoryFormSectionView(title: AppString.color) {
            CategoryColorPickerView(colorHex: $viewModel.formData.colorHex)
        }
    }
}

// MARK: - Actions
private extension AddEditCategoryView {

    func handleSave() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        withAnimation {
            if viewModel.save(context: context) {
                isTabBarVisible.wrappedValue = true
                dismiss()
            }
        }
    }
}

#Preview("New Category") {
    NavigationStack {
        AddEditCategoryView()
    }
}

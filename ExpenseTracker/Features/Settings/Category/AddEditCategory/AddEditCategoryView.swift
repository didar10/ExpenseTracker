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

    @State private var viewModel: AddEditCategoryViewModel
    @State private var showingDiscardConfirmation = false

    // MARK: - Init

    init(category: Category? = nil) {
        _viewModel = State(initialValue: AddEditCategoryViewModel(category: category))
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                form
            }

            saveBar
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        // Введенные данные не теряются молча: закрытие проходит через подтверждение
        .interactiveDismissDisabled(viewModel.hasUnsavedChanges)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button(AppString.done, action: dismissKeyboard)
            }
        }
        .alert(AppString.discardCategoryTitle, isPresented: $showingDiscardConfirmation) {
            Button(AppString.discardChanges, role: .destructive) { dismiss() }
            Button(AppString.keepEditing, role: .cancel) { }
        } message: {
            Text(AppString.discardChangesMessage)
        }
    }
}

// MARK: - Subviews
private extension AddEditCategoryView {

    var header: some View {
        SheetHeaderView(title: viewModel.title, onClose: handleClose)
    }

    var form: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xLarge) {
                NamePreviewCardView(
                    name: $viewModel.formData.name,
                    icon: viewModel.formData.icon,
                    color: Color(hex: viewModel.formData.colorHex),
                    placeholder: AppString.categoryName
                )

                TransactionTypePickerView(
                    selectedType: $viewModel.formData.type,
                    backgroundColor: AppColor.fieldFill
                )

                colorSection
                iconSection
            }
            .padding(AppSpacing.large)
            .padding(.bottom, AppSpacing.huge + AppSpacing.xxxLarge)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    var colorSection: some View {
        ColorPickerView(selectedColor: $viewModel.formData.colorHex, palette: .hex)
    }

    var iconSection: some View {
        IconPicker(
            selectedIcon: $viewModel.formData.icon,
            color: Color(hex: viewModel.formData.colorHex)
        )
    }

    var saveBar: some View {
        CategorySaveButtonView(
            title: viewModel.saveButtonTitle,
            isEnabled: viewModel.canSave,
            action: handleSave
        )
        .padding(.horizontal, AppSpacing.large)
        .padding(.top, AppSpacing.medium)
        .padding(.bottom, AppSpacing.large)
        .background(
            AppColor.background
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Actions
private extension AddEditCategoryView {

    func handleSave() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        dismissKeyboard()

        if viewModel.save(context: context) {
            dismiss()
        }
    }

    func handleClose() {
        dismissKeyboard()

        guard viewModel.hasUnsavedChanges else {
            dismiss()
            return
        }

        showingDiscardConfirmation = true
    }

    func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

#Preview("Новая категория") {
    AddEditCategoryView()
        .modelContainer(for: [Category.self], inMemory: true)
}

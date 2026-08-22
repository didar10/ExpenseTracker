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

            saveBar
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(AppString.done) {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
            }
        }
    }
}

// MARK: - Subviews
private extension AddEditCategoryView {

    var header: some View {
        ZStack {
            AppText(viewModel.title, style: .bodySmall)

            HStack {
                ToolbarIconButton(icon: "xmark", isOutlined: true) {
                    dismiss()
                }

                Spacer()
            }
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.small)
        .padding(.top, AppSpacing.medium)
    }

    var iconSection: some View {
        IconPicker(
            selectedIcon: $viewModel.formData.icon,
            colorHex: viewModel.formData.colorHex
        )
    }

    var colorSection: some View {
        ColorPickerView(selectedColor: $viewModel.formData.colorHex, palette: .hex)
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

        withAnimation {
            if viewModel.save(context: context) {
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

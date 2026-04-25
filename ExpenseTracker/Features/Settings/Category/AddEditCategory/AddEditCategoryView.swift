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
        ZStack(alignment: .bottom) {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: AppSpacing.xLarge) {
                        CategoryPreviewCardView(
                            name: viewModel.formData.name,
                            icon: viewModel.formData.icon,
                            colorHex: viewModel.formData.colorHex
                        )

                        nameSection
                        iconSection
                        colorSection
                    }
                    .padding(AppSpacing.large)
                    .padding(.bottom, AppSpacing.huge + AppSpacing.xxxLarge)
                }
            }

            saveBar
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            isTabBarVisible.wrappedValue = false
        }
    }
}

// MARK: - Subviews
private extension AddEditCategoryView {

    var header: some View {
        ZStack {
            AppText(viewModel.title, style: .section)

            HStack {
                ToolbarIconButton(icon: "chevron.left", isOutlined: true) {
                    isTabBarVisible.wrappedValue = true
                    dismiss()
                }

                Spacer()
            }
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.small)
    }

    var nameSection: some View {
        CategoryFormSectionView(title: AppString.name.uppercased()) {
            TextField(AppString.categoryNameExample, text: $viewModel.formData.name)
                .font(.app(.body))
                .padding(AppSpacing.large)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .fill(AppColor.cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .strokeBorder(
                            AppColor.textPrimary.opacity(0.15),
                            lineWidth: AppSpacing.hairline
                        )
                )
        }
    }

    var iconSection: some View {
        CategoryFormSectionView(title: AppString.icon.uppercased()) {
            IconPicker(
                selectedIcon: $viewModel.formData.icon,
                colorHex: viewModel.formData.colorHex
            )
        }
    }

    var colorSection: some View {
        CategoryFormSectionView(title: AppString.color.uppercased()) {
            CategoryColorPickerView(colorHex: $viewModel.formData.colorHex)
        }
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

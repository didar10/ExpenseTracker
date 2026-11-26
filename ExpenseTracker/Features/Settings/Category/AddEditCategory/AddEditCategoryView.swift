import SwiftData
import SwiftUI

struct AddEditCategoryView: View {
    @Query private var categories: [Category]
    @Environment(\.repositories) private var repositories
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: AddEditCategoryViewModel
    @State private var deletion = CategoryListViewModel()
    @State private var showingDiscardConfirmation = false

    init(category: Category? = nil, initialType: TransactionType = .expense, showsSaveError: Bool = false) {
        let viewModel = AddEditCategoryViewModel(category: category, initialType: initialType)
        viewModel.showingSaveError = showsSaveError
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        let nameError = viewModel.nameError(in: categories)

        VStack(spacing: .zero) {
            SheetGrabber()
            header.padding(.horizontal, DS.Spacing.xl)
            ScrollView {
                form(nameError: nameError)
                    .padding(.horizontal, DS.Spacing.xl)
                    .padding(.vertical, DS.CategoryManagement.sectionSpacing)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
        }
        .padding(.top, SheetGrabber.topPadding)
        .background(DS.Color.bg)
        .safeAreaInset(edge: .bottom, spacing: .zero) { saveBar(disabled: nameError != nil) }
        .brutalSheetPresentation(detents: [.large])
        .interactiveDismissDisabled(viewModel.hasUnsavedChanges)
        .sensoryFeedback(.selection, trigger: viewModel.formData.colorHex)
        .sensoryFeedback(.selection, trigger: viewModel.formData.icon)
        .onChange(of: viewModel.formData.name) { viewModel.clearSaveNameError() }
        .saveErrorAlert(isPresented: $viewModel.showingSaveError)
        .brutalAlert(
            isPresented: $deletion.showDeleteAlert,
            title: AppString.deleteCategoryConfirm,
            message: deletion.deleteMessage,
            confirmTitle: AppString.delete,
            onConfirm: deleteCategory,
            onCancel: deletion.cancelDelete
        )
        .brutalAlert(
            isPresented: $showingDiscardConfirmation,
            title: AppString.discardCategoryTitle,
            message: AppString.discardChangesMessage,
            confirmTitle: AppString.discardChanges,
            onConfirm: { dismiss() }
        )
    }

    private var header: some View {
        HStack(spacing: DS.Spacing.sm) {
            IconButton(icon: DS.Icon.close, accessibilityLabel: AppString.accessibilityClose, action: handleClose)
            Text(viewModel.title)
                .font(DS.Font.dialogTitle)
                .foregroundStyle(DS.Color.ink)
                .lineLimit(1)
                .minimumScaleFactor(DS.CategoryManagement.minimumScale)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)
            if let category = viewModel.category {
                Button {
                    dismissKeyboard()
                    deletion.prepareDelete(category)
                } label: {
                    DS.Icon.trash
                        .font(.system(size: DS.Size.iconM, weight: .semibold))
                        .frame(width: DS.Size.control, height: DS.Size.control)
                }
                .buttonStyle(.pressIntoShadow(.danger))
                .frame(width: DS.Size.control, height: DS.Size.control)
                .accessibilityLabel(AppString.deleteCategoryConfirm)
            } else {
                Color.clear.frame(width: DS.Size.control, height: DS.Size.control).accessibilityHidden(true)
            }
        }
    }

    private func form(nameError: CategoryNameError?) -> some View {
        @Bindable var viewModel = viewModel
        let color = Binding(
            get: { DS.AccountColor(categoryHex: viewModel.formData.colorHex) },
            set: { viewModel.formData.colorHex = $0.categoryHex }
        )

        return VStack(spacing: DS.CategoryManagement.sectionSpacing) {
            HStack(spacing: DS.CategoryManagement.sectionSpacing) {
                previewTile(color: color.wrappedValue)
                BrutalTextField(
                    AppString.categoryName,
                    text: $viewModel.formData.name,
                    placeholder: AppString.accountFormName,
                    errorMessage: nameMessage(nameError),
                    showsInlineLabel: false
                )
                .textInputAutocapitalization(.sentences)
                .submitLabel(.done)
                .onSubmit(dismissKeyboard)
            }

            SegmentedSwitch(selection: $viewModel.formData.type, options: [
                .init(value: .expense, title: AppString.expense, icon: Image(systemName: "arrow.up.right")),
                .init(value: .income, title: AppString.income, icon: Image(systemName: "arrow.down.left"))
            ])
            .disabled(viewModel.isEditMode)

            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Text(AppString.color).dsLabel()
                ColorSwatchGrid(selection: color)
            }

            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Text(AppString.icon).dsLabel()
                IconPicker(selection: $viewModel.formData.icon, originalIcon: viewModel.originalIcon)
            }
        }
    }

    private func previewTile(color: DS.AccountColor) -> some View {
        Image(systemName: viewModel.formData.icon)
            .font(.system(size: DS.Size.iconAdd, weight: .semibold))
            .foregroundStyle(color.foreground)
            .frame(width: DS.CategoryForm.previewSide, height: DS.CategoryForm.previewSide)
            .background(color.color, in: RoundedRectangle(cornerRadius: DS.Radius.tabBar))
            .brutalBorder(radius: DS.Radius.tabBar)
            .hardShadow(.hardSmall)
            .accessibilityHidden(true)
    }

    private func nameMessage(_ error: CategoryNameError?) -> String? {
        switch error {
        case .empty: AppString.enterName
        case .duplicate: AppString.duplicateCategoryName
        case nil: nil
        }
    }

    private func saveBar(disabled: Bool) -> some View {
        PrimaryButton(title: viewModel.saveButtonTitle, icon: DS.Icon.checkmark) {
            guard viewModel.nameError(in: categories) == nil else { return }
            dismissKeyboard()
            if viewModel.save(using: repositories.categories) { dismiss() }
        }
        .disabled(disabled)
        .padding(.horizontal, DS.Spacing.xl)
        .padding(.top, DS.Spacing.md)
        .padding(.bottom, DS.Spacing.sm)
        .background(DS.Color.bg)
    }

    private func deleteCategory() {
        if deletion.confirmDelete(using: repositories.categories) {
            dismiss()
        } else {
            viewModel.showingSaveError = deletion.showingSaveError
        }
    }

    private func handleClose() {
        dismissKeyboard()
        if viewModel.hasUnsavedChanges { showingDiscardConfirmation = true } else { dismiss() }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#if DEBUG
#Preview("Новая") { AddEditCategoryView().fixture(FixtureEnvironment(.empty)) }
#Preview("Новая · тёмная") { AddEditCategoryView().fixture(FixtureEnvironment(.empty)).preferredColorScheme(.dark) }
#Preview("Редактирование") { categoryFormEditPreview() }
#Preview("Редактирование · тёмная") { categoryFormEditPreview().preferredColorScheme(.dark) }
#Preview("Ошибка сохранения") { AddEditCategoryView(showsSaveError: true).fixture(FixtureEnvironment(.empty)) }
#Preview("Ошибка сохранения · тёмная") {
    AddEditCategoryView(showsSaveError: true).fixture(FixtureEnvironment(.empty)).preferredColorScheme(.dark)
}

@MainActor
private func categoryFormEditPreview() -> some View {
    let fixture = FixtureEnvironment(.empty)
    let category = Category(name: "Кафе и рестораны", icon: "cup.and.saucer", colorHex: "#FFB0A8")
    fixture.context.insert(category)
    return AddEditCategoryView(category: category).fixture(fixture)
}
#endif

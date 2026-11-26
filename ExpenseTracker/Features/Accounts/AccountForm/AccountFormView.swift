import SwiftData
import SwiftUI

/// Создание и редактирование счета. Прокрутка и safeAreaInset сохраняют доступ
/// к активному полю и главной кнопке при появлении клавиатуры.
struct AccountFormView: View {
    @Environment(\.repositories) private var repositories
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AccountFormViewModel
    private enum Field: Hashable { case name, balance }
    @State private var focusedField: Field?
    @State private var showingDeleteAlert = false
    @State private var showingDiscardConfirmation = false

    @MainActor
    init(account: Account? = nil, viewModel: AccountFormViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? AccountFormViewModel(account: account))
    }

    var body: some View {
        VStack(spacing: .zero) {
            SheetGrabber()
            header.padding(.horizontal, DS.Spacing.xl)
            ScrollViewReader { proxy in
                ScrollView {
                    form
                        .padding(.horizontal, DS.Spacing.xl)
                        .padding(.vertical, DS.AccountForm.spacing)
                }
                .scrollDismissesKeyboard(.interactively)
                .scrollBounceBehavior(.basedOnSize)
                .scrollIndicators(.hidden)
                .onChange(of: focusedField) { _, field in
                    if let field { proxy.scrollTo(field, anchor: .center) }
                }
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { _ in
                    if let focusedField { proxy.scrollTo(focusedField, anchor: .center) }
                }
            }
        }
        .padding(.top, SheetGrabber.topPadding)
        .background(DS.Color.bg)
        .safeAreaInset(edge: .bottom, spacing: .zero) { saveBar }
        .brutalSheetPresentation(detents: [.large])
        .interactiveDismissDisabled(viewModel.hasUnsavedChanges)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(AppString.done, action: dismissKeyboard)
            }
        }
        .sensoryFeedback(.selection, trigger: viewModel.selectedKind)
        .sensoryFeedback(.selection, trigger: viewModel.selectedColor)
        .saveErrorAlert(isPresented: $viewModel.showingSaveError)
        .brutalAlert(
            isPresented: $showingDeleteAlert,
            title: viewModel.deletionTitle,
            message: AppString.deleteAccountMessage,
            confirmTitle: AppString.delete,
            onConfirm: {
                if viewModel.delete(using: repositories.accounts) { dismiss() }
            }
        )
        .brutalAlert(
            isPresented: $showingDiscardConfirmation,
            title: AppString.discardAccountTitle,
            message: AppString.discardChangesMessage,
            confirmTitle: AppString.discardChanges,
            onConfirm: { dismiss() }
        )
    }

    private var header: some View {
        HStack(spacing: DS.Spacing.sm) {
            IconButton(icon: DS.Icon.close, accessibilityLabel: AppString.accessibilityClose, action: handleClose)
            Text(viewModel.navigationTitle)
                .font(viewModel.isEditMode ? DS.Font.accountFormEditTitle : DS.Font.dialogTitle)
                .foregroundStyle(DS.Color.ink)
                .lineLimit(1)
                .minimumScaleFactor(DS.AccountForm.minimumScale)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)
            if viewModel.isEditMode {
                Button {
                    dismissKeyboard()
                    showingDeleteAlert = true
                } label: {
                    DS.Icon.trash
                        .font(.system(size: DS.Size.iconM, weight: .semibold))
                        .frame(width: DS.Size.control, height: DS.Size.control)
                }
                .buttonStyle(PressIntoShadowStyle(variant: .danger))
                .frame(width: DS.Size.control, height: DS.Size.control)
                .accessibilityLabel(AppString.deleteAccount)
            } else {
                Color.clear.frame(width: DS.Size.control, height: DS.Size.control).accessibilityHidden(true)
            }
        }
    }

    private var form: some View {
        VStack(spacing: DS.AccountForm.spacing) {
            AccountPreviewCard(
                name: viewModel.trimmedName,
                amount: viewModel.previewBalance,
                icon: viewModel.selectedIcon,
                color: DS.AccountColor(name: viewModel.selectedColor)
            )
            BrutalTextField(AppString.accountFormName, text: $viewModel.name, placeholder: AppString.accountNamePlaceholder,
                            onFocusChange: { updateFocus(.name, isFocused: $0) })
                .id(Field.name)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .onSubmit(dismissKeyboard)

            BrutalTextField(AppString.initialBalance, text: $viewModel.balanceInput, placeholder: "0", kind: .amount,
                            onFocusChange: { updateFocus(.balance, isFocused: $0) })
                .id(Field.balance)

            SegmentedSwitch(selection: $viewModel.selectedKind, options: AccountKind.allCases.map {
                .init(value: $0, title: $0.title)
            }, fill: .ink)
            .accessibilityLabel(AppString.accountKind)

            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Text(AppString.color).dsLabel().padding(.horizontal, DS.Spacing.xs)
                ColorSwatchGrid(selection: Binding(
                    get: { DS.AccountColor(name: viewModel.selectedColor) },
                    set: { viewModel.selectedColor = $0.rawValue }
                ))
            }

            Card(padding: EdgeInsets(top: DS.Spacing.sm, leading: DS.Spacing.md, bottom: DS.Spacing.sm, trailing: DS.AccountList.trailingPadding)) {
                BrutalToggle(AppString.defaultAccount, subtitle: AppString.defaultAccountHint, isOn: $viewModel.isDefault)
                    .frame(minHeight: DS.Size.control)
            }
        }
    }

    private var saveBar: some View {
        PrimaryButton(title: viewModel.saveButtonTitle, icon: DS.Icon.checkmark, action: handleSave)
            .disabled(!viewModel.isValid)
            .accessibilityIdentifier(AccessibilityID.accountFormSave)
            .padding(.horizontal, DS.Spacing.xl)
            .padding(.top, DS.Spacing.md)
            .padding(.bottom, DS.Spacing.sm)
            .background(DS.Color.bg)
    }

    private func updateFocus(_ field: Field, isFocused: Bool) {
        if isFocused { focusedField = field }
        else if focusedField == field { focusedField = nil }
    }

    private func handleSave() {
        dismissKeyboard()
        if viewModel.save(using: repositories.accounts) { dismiss() }
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
private struct AccountFormPreview: View {
    var editing = false
    var showsError = false

    var body: some View {
        let environment = FixtureEnvironment(.empty)
        let account = Account(name: "Наличные", icon: AccountKind.cash.icon, color: "green", initialBalance: 32_000)
        if editing { environment.context.insert(account) }
        let viewModel = AccountFormViewModel(account: editing ? account : nil)
        viewModel.showingSaveError = showsError
        return AccountFormView(viewModel: viewModel).fixture(environment)
    }
}
#Preview("Новый · светлая") { AccountFormPreview() }
#Preview("Новый · темная") { AccountFormPreview().preferredColorScheme(.dark) }
#Preview("Редактирование · светлая") { AccountFormPreview(editing: true) }
#Preview("Редактирование · темная") { AccountFormPreview(editing: true).preferredColorScheme(.dark) }
#Preview("Ошибка · светлая") { AccountFormPreview(showsError: true) }
#Preview("Ошибка · темная") { AccountFormPreview(showsError: true).preferredColorScheme(.dark) }
#endif

//
//  AddBudgetView.swift
//  ExpenseTracker
//
//  Created by Didar on 26.11.2026.
//

import SwiftData
import SwiftUI

/// «Новый бюджет» — лист во всю высоту: ✕ и заголовок, лента категорий, сумма «в месяц»
/// с пресетами, период, переключатели, клавиатура 3×4, подсказка о лимите и «Создать бюджет».
///
/// На низком листе (iPhone SE, mini) нет переключателя периода, а переключатели — одной строкой:
/// иначе экран не помещается без прокрутки
struct AddBudgetView: View {

    // MARK: - Properties

    @State private var viewModel: AddBudgetViewModel
    @State private var categorySheet: CategoryListSheetMode?
    @State private var isCompact = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.repositories) private var repositories
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Init

    init(viewModel: AddBudgetViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            SheetGrabber()

            header
                .padding(.horizontal, DS.Spacing.xl)

            CategoryCarousel(
                categories: viewModel.carouselItems,
                selection: $viewModel.selectedCategoryID,
                style: .compact,
                noCategoryCaption: AppString.addBudgetSwipeHint,
                onSearch: { categorySheet = .search },
                onAllCategories: { categorySheet = .browse }
            )
            .padding(.top, DS.Spacing.md)

            form
                .padding(.horizontal, DS.Spacing.xl)
        }
        .padding(.top, SheetGrabber.topPadding)
        .background(DS.Color.bg)
        .onGeometryChange(for: Bool.self) { $0.size.height < Metrics.compactHeight } action: { isCompact = $0 }
        .sensoryFeedback(.selection, trigger: viewModel.selectedCategoryID)
        .sensoryFeedback(.selection, trigger: viewModel.input)
        .brutalSheet(item: $categorySheet, title: { _ in AppString.categories }, detents: [.large]) { mode in
            CategoryListSheetContent(
                categories: viewModel.carouselItems,
                selection: viewModel.selectedCategoryID,
                focusesSearch: mode == .search
            ) { id in
                viewModel.selectedCategoryID = id
                categorySheet = nil
            }
        }
        .saveErrorAlert(isPresented: $viewModel.showingSaveError)
    }
}

// MARK: - Subviews

private extension AddBudgetView {

    var header: some View {
        ZStack {
            Text(AppString.newBudget)
                .font(DS.Font.dialogTitle)
                .foregroundStyle(DS.Color.ink)
                .lineLimit(1)
                .padding(.horizontal, DS.Size.control + DS.Spacing.sm)
                .accessibilityAddTraits(.isHeader)

            IconButton(icon: DS.Icon.close, accessibilityLabel: AppString.accessibilityClose) {
                dismiss()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var form: some View {
        VStack(spacing: .zero) {
            amount
                .padding(.top, isCompact ? DS.Spacing.sm : Metrics.amountTop)

            PresetChips(
                chips: viewModel.presets,
                isSelected: viewModel.isSelected,
                fillsWidth: true,
                onSelect: viewModel.selectPreset
            )
            .padding(.top, DS.Spacing.sm)

            if !isCompact {
                periodSwitch
                    .padding(.top, DS.Spacing.md)
            }

            BudgetOptionsView(
                carriesOverRemainder: $viewModel.carriesOverRemainder,
                warnsNearLimit: $viewModel.warnsNearLimit,
                isCompact: isCompact
            )
            .padding(.top, Metrics.optionsTop)

            Spacer(minLength: DS.Spacing.sm)

            CalculatorKeypad(layout: .amount, onKey: viewModel.press)

            limitHint
                .padding(.top, DS.Spacing.sm)
                .padding(.bottom, Metrics.hintBottom)

            PrimaryButton(
                title: viewModel.saveButtonTitle,
                icon: viewModel.canSave ? DS.Icon.checkmark : nil,
                action: save
            )
            .disabled(!viewModel.canSave)
        }
        .padding(.bottom, DS.Spacing.md)
    }

    var amount: some View {
        HStack(alignment: .firstTextBaseline, spacing: DS.Spacing.sm) {
            Text(MoneyFormat.number(viewModel.amount))
                .font(DS.Font.amountInput)
                .foregroundStyle(viewModel.isAmountEmpty ? DS.Color.ink2 : DS.Color.ink)
                .lineLimit(1)
                .minimumScaleFactor(Metrics.amountMinimumScale)
                .contentTransition(.numericText())
                .animation(reduceMotion ? nil : DS.Motion.press, value: viewModel.input)

            Text(AppString.currencySymbol)
                .font(DS.Font.amountSignS)
                .foregroundStyle(DS.Color.ink2)

            Text(AppString.addBudgetPerMonth)
                .dsLabel()
                .padding(.leading, DS.Spacing.xs)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    /// Неделя и год видны, но пока недоступны: экран «Бюджеты» только месячный
    var periodSwitch: some View {
        SegmentedSwitch(
            selection: .constant(viewModel.period),
            options: BudgetPeriod.allCases.map { period in
                .init(value: period, title: period.displayName, isEnabled: viewModel.availablePeriods.contains(period))
            },
            fill: .ink
        )
        .accessibilityLabel(AppString.addBudgetPeriod)
    }

    /// Пустая строка держит высоту, чтобы клавиатура не прыгала при вводе первой цифры
    var limitHint: some View {
        Group {
            if let hint = viewModel.limitHint {
                Text(highlighted(hint.text, part: hint.highlighted))
            } else {
                Text(AppString.currencySymbol)
                    .hidden()
                    .accessibilityHidden(true)
            }
        }
        .font(DS.Font.captionSmall)
        .foregroundStyle(DS.Color.ink2)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
    }

    /// Сумма остатка — жирным моноширинным цветом ink
    func highlighted(_ text: String, part: String) -> AttributedString {
        var result = AttributedString(text)
        if let range = result.range(of: part, options: .backwards) {
            result[range].font = DS.Font.moneySmallBold
            result[range].foregroundColor = DS.Color.ink
        }
        return result
    }
}

// MARK: - Actions

private extension AddBudgetView {

    func save() {
        if viewModel.save(using: repositories.budgets) {
            dismiss()
        }
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/AddBudget.html`
    static let amountTop: CGFloat = 10
    static let optionsTop: CGFloat = 10
    static let hintBottom: CGFloat = 6
    static let amountMinimumScale: CGFloat = 0.5
    /// Ниже этой высоты листа (iPhone SE, mini) — компактная раскладка: полной нужно ≈735 pt
    static let compactHeight: CGFloat = 730
}

// MARK: - Previews

#if DEBUG
private struct AddBudgetPreview: View {

    var hasLimit = true
    var selectsCategory = false
    /// false — без листа, в рамке размера листа iPhone SE
    var presentsAsSheet = true

    var body: some View {
        let environment = FixtureEnvironment(.sample)
        let categories = (try? environment.context.fetch(FetchDescriptor<Category>(sortBy: [SortDescriptor(\.name)]))) ?? []
        let viewModel = AddBudgetViewModel(
            categories: categories,
            budgetPlans: [],
            transactions: (try? environment.context.fetch(FetchDescriptor<Transaction>())) ?? [],
            limit: hasLimit ? 250_000 : nil
        )
        if selectsCategory {
            viewModel.selectedCategoryID = viewModel.carouselItems.first?.id
            viewModel.selectPreset(45_000)
        }

        return Group {
            if presentsAsSheet {
                Color.clear
                    .brutalCustomSheet(isPresented: .constant(true)) {
                        AddBudgetView(viewModel: viewModel)
                    }
            } else {
                AddBudgetView(viewModel: viewModel)
                    .frame(width: SEPreview.width, height: SEPreview.sheetHeight)
            }
        }
        .fixture(environment)
    }
}

#Preview("Пусто · светлая") {
    AddBudgetPreview()
}

#Preview("Пусто · темная") {
    AddBudgetPreview()
        .preferredColorScheme(.dark)
}

#Preview("Заполнено · светлая") {
    AddBudgetPreview(selectsCategory: true)
}

#Preview("Заполнено · темная") {
    AddBudgetPreview(selectsCategory: true)
        .preferredColorScheme(.dark)
}

#Preview("Без лимита · светлая") {
    AddBudgetPreview(hasLimit: false, selectsCategory: true)
}

/// Лист во всю высоту на iPhone SE: 667 − статус-бар 20 − зазор листа 10
private enum SEPreview {
    static let width: CGFloat = 375
    static let sheetHeight: CGFloat = 637
}

#Preview("iPhone SE · светлая") {
    AddBudgetPreview(selectsCategory: true, presentsAsSheet: false)
}

#Preview("iPhone SE · темная") {
    AddBudgetPreview(selectsCategory: true, presentsAsSheet: false)
        .preferredColorScheme(.dark)
}
#endif

import SwiftData
import SwiftUI

struct CategoriesListView: View {
    @Query(sort: \Category.name) private var categories: [Category]
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]

    @AppStorage("categoryOrder.expense") private var expenseOrder = ""
    @AppStorage("categoryOrder.income") private var incomeOrder = ""
    @Environment(\.repositories) private var repositories
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var viewModel: CategoryListViewModel
    @State private var selectedType: TransactionType
    @State private var isEditing: Bool
    @State private var showingAddCategory = false
    @State private var editingCategory: Category?
    @State private var viewingCategory: Category?
    @State private var rowFrames: [UUID: CGRect] = [:]
    @GestureState private var dragTarget: UUID?

    init(initialType: TransactionType = .expense, isEditing: Bool = false, viewModel: CategoryListViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? CategoryListViewModel())
        _selectedType = State(initialValue: initialType)
        _isEditing = State(initialValue: isEditing)
    }

    private var visibleCategories: [Category] {
        let order = selectedType == .expense ? expenseOrder : incomeOrder
        return CategoryListViewModel.ordered(
            categories.filter { !$0.isDeleted && $0.type == selectedType },
            by: order.split(separator: ",").compactMap { UUID(uuidString: String($0)) }
        )
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        let rows = visibleCategories
        let now = Date.now
        let summary = CategoryMonthSummary(transactions: transactions, type: selectedType, now: now)

        VStack(spacing: DS.CategoryManagement.sectionSpacing) {
            header(hasCategories: !rows.isEmpty)
            SegmentedSwitch(selection: $selectedType, options: [
                .init(value: .expense, title: AppString.expenses, icon: Image(systemName: "arrow.up.right")),
                .init(value: .income, title: AppString.incomes, icon: Image(systemName: "arrow.down.left"))
            ])

            ScrollView {
                if rows.isEmpty {
                    EmptyCategoriesView { showingAddCategory = true }
                } else {
                    VStack(spacing: DS.Spacing.md) {
                        Card(padding: nil) {
                            VStack(spacing: .zero) {
                                ForEach(Array(rows.enumerated()), id: \.element.id) { index, category in
                                    if index > 0 { ListDivider() }
                                    row(category, caption: summary.caption(for: category.id), in: rows)
                                }
                            }
                        }
                        if !isEditing { addCategoryButton }
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, DS.Spacing.xl)
        .padding(.top, DS.Spacing.xs)
        .padding(.bottom, DS.Spacing.sm)
        .background(DS.Color.bg)
        .onChange(of: selectedType) { isEditing = false }
        .onChange(of: rows.isEmpty) { _, empty in
            if empty { isEditing = false }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddEditCategoryView(initialType: selectedType)
        }
        .sheet(item: $editingCategory) { category in
            AddEditCategoryView(category: category)
        }
        .sheet(item: $viewingCategory) { category in
            CategoryTransactionsView(
                category: category,
                scope: CategoryTransactionsScope(period: .month, interval: summary.interval, title: summary.title, type: selectedType)
            )
        }
        .brutalAlert(
            isPresented: $viewModel.showDeleteAlert,
            title: AppString.deleteCategoryConfirm,
            message: viewModel.deleteMessage,
            confirmTitle: AppString.delete,
            onConfirm: { viewModel.confirmDelete(using: repositories.categories) },
            onCancel: viewModel.cancelDelete
        )
        .saveErrorAlert(isPresented: $viewModel.showingSaveError)
    }

    private func header(hasCategories: Bool) -> some View {
        HStack(spacing: DS.Spacing.sm) {
            editLabel.hidden().overlay(alignment: .leading) {
                IconButton(icon: DS.Icon.chevronLeft, accessibilityLabel: AppString.categoryBack) { dismiss() }
            }
            Text(AppString.categories)
                .font(DS.Font.dialogTitle)
                .foregroundStyle(DS.Color.ink)
                .lineLimit(1)
                .minimumScaleFactor(DS.CategoryManagement.minimumScale)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)
            Button {
                withAnimation(reduceMotion ? nil : DS.Motion.toggle) { isEditing.toggle() }
            } label: {
                editLabel
            }
            .buttonStyle(.outlineClick)
            .disabled(!hasCategories)
        }
    }

    private var editLabel: some View {
        Text(isEditing ? AppString.done : AppString.edit)
            .font(DS.Font.control)
            .lineLimit(1)
            .padding(.horizontal, DS.Spacing.md)
            .frame(minWidth: DS.Size.control, minHeight: DS.Size.control)
    }

    private func row(_ category: Category, caption: String, in rows: [Category]) -> some View {
        let id = category.id
        return HStack(spacing: DS.Spacing.md) {
            if isEditing {
                Button { viewModel.prepareDelete(category) } label: {
                    DS.Icon.minus
                        .font(.system(size: DS.Size.iconXS, weight: .bold))
                        .frame(width: DS.CategoryManagement.deleteSize, height: DS.CategoryManagement.deleteSize)
                        .frame(minHeight: DS.Size.control)
                }
                .buttonStyle(.outlineClickDelete(diameter: DS.CategoryManagement.deleteSize, fill: DS.Color.accountRed))
                .accessibilityLabel("\(AppString.delete) \(category.name)")
            }

            Button {
                if isEditing { editingCategory = category } else { viewingCategory = category }
            } label: {
                HStack(spacing: DS.Spacing.md) {
                    CategoryTile(icon: Image(systemName: category.icon), color: .init(legacyHex: category.colorHex), size: .medium)
                    VStack(alignment: .leading, spacing: DS.CategoryManagement.captionSpacing) {
                        Text(category.name)
                            .font(DS.Font.bodyBold)
                            .foregroundStyle(DS.Color.ink)
                        Text(caption)
                            .font(DS.Font.moneySmall)
                            .foregroundStyle(DS.Color.ink2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    if !isEditing {
                        DS.Icon.chevronRight
                            .font(.system(size: DS.Size.iconXS, weight: .semibold))
                            .accessibilityHidden(true)
                    }
                }
                .frame(minHeight: DS.CategoryManagement.rowHeight)
                .contentShape(Rectangle())
            }
            // Вне правки строка — одна кнопка: щелчок подсвечивает ее вместе с отступами
            .buttonStyle(.outlineClickRow(bleed: isEditing ? EdgeInsets() : EdgeInsets(
                top: .zero,
                leading: DS.Spacing.md,
                bottom: .zero,
                trailing: DS.CategoryManagement.sectionSpacing
            )))

            if isEditing {
                DS.Icon.equal
                    .font(.system(size: DS.Size.iconM, weight: .semibold))
                    .frame(width: DS.Size.control, height: DS.Size.control)
                    .contentShape(Rectangle())
                    .gesture(reorderGesture(for: id, in: rows))
                    .accessibilityLabel("\(AppString.categoryMove) \(category.name)")
                    .accessibilityAction(named: AppString.moveAccountUp) { move(id, by: -1, in: rows) }
                    .accessibilityAction(named: AppString.moveAccountDown) { move(id, by: 1, in: rows) }
            }
        }
        .padding(.leading, DS.Spacing.md)
        .padding(.trailing, DS.CategoryManagement.sectionSpacing)
        .foregroundStyle(DS.Color.ink)
        .background(dragTarget == id ? DS.Color.line : DS.Color.surface)
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame in
            rowFrames[id] = frame
        }
        .onDisappear { rowFrames[id] = nil }
    }

    private func reorderGesture(for source: UUID, in rows: [Category]) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .updating($dragTarget) { value, target, _ in
                target = destination(at: value.location.y, in: rows)
            }
            .onEnded { value in
                guard let target = destination(at: value.location.y, in: rows) else { return }
                _ = move(source, to: target, in: rows)
            }
    }

    private func destination(at y: CGFloat, in rows: [Category]) -> UUID? {
        rows.first { row in
            guard let frame = rowFrames[row.id] else { return false }
            return y >= frame.minY && y < frame.maxY
        }?.id
    }

    private var addCategoryButton: some View {
        Button { showingAddCategory = true } label: {
            Label { Text(AppString.newCategory) } icon: { DS.Icon.plus }
                .font(DS.Font.buttonSmall)
                .frame(maxWidth: .infinity, minHeight: DS.Size.menuRow)
                .contentShape(Rectangle())
                .overlay {
                    RoundedRectangle(cornerRadius: DS.Radius.control)
                        .strokeBorder(DS.Color.ink, style: StrokeStyle(lineWidth: DS.Stroke.regular, dash: DS.Stroke.dash))
                }
        }
        .buttonStyle(.outlineClickSegment)
    }

    private func move(_ source: UUID, by offset: Int, in rows: [Category]) {
        guard let index = rows.firstIndex(where: { $0.id == source }), rows.indices.contains(index + offset) else { return }
        _ = move(source, to: rows[index + offset].id, in: rows)
    }

    private func move(_ source: UUID, to target: UUID, in rows: [Category]) -> Bool {
        guard let order = CategoryListViewModel.moved(source, to: target, in: rows.map(\.id)) else { return false }
        let encoded = order.map(\.uuidString).joined(separator: ",")
        withAnimation(reduceMotion ? nil : DS.Motion.toggle) {
            if selectedType == .expense { expenseOrder = encoded } else { incomeOrder = encoded }
        }
        return true
    }
}

#if DEBUG
#Preview("Расходы") { CategoriesListView().fixture(FixtureEnvironment(.sample)) }
#Preview("Расходы · тёмная") { CategoriesListView().fixture(FixtureEnvironment(.sample)).preferredColorScheme(.dark) }
#Preview("Доходы") { CategoriesListView(initialType: .income).fixture(FixtureEnvironment(.sample)) }
#Preview("Доходы · тёмная") {
    CategoriesListView(initialType: .income).fixture(FixtureEnvironment(.sample)).preferredColorScheme(.dark)
}
#Preview("Редактирование") { CategoriesListView(isEditing: true).fixture(FixtureEnvironment(.sample)) }
#Preview("Редактирование · тёмная") {
    CategoriesListView(isEditing: true).fixture(FixtureEnvironment(.sample)).preferredColorScheme(.dark)
}
#Preview("Пусто") { CategoriesListView().fixture(FixtureEnvironment(.empty)) }
#Preview("Пусто · тёмная") { CategoriesListView().fixture(FixtureEnvironment(.empty)).preferredColorScheme(.dark) }
#Preview("Ошибка сохранения") { categoryErrorPreview() }
#Preview("Ошибка сохранения · тёмная") { categoryErrorPreview().preferredColorScheme(.dark) }

@MainActor
private func categoryErrorPreview() -> some View {
    let viewModel = CategoryListViewModel()
    viewModel.showingSaveError = true
    return CategoriesListView(viewModel: viewModel).fixture(FixtureEnvironment(.sample))
}
#endif

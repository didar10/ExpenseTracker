import SwiftData
import SwiftUI

struct CategoryTransactionsView: View {
    let category: Category
    let scope: CategoryTransactionsScope
    var accountSelection = AccountSelectionStore()

    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.repositories) private var repositories
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var editingTransaction: Transaction?
    @State private var duplicatedTransaction: Transaction?
    @State private var deletion = TransactionDeletionState()

    var body: some View {
        @Bindable var deletion = deletion
        let visible = scope.transactions(from: transactions, categoryID: category.id)
        let total = visible.reduce(Decimal.zero) { $0 + $1.amount }

        VStack(spacing: .zero) {
            header
                .padding(.horizontal, DS.Spacing.xl)
                .padding(.top, DS.Spacing.xs)

            ScrollView {
                VStack(spacing: .zero) {
                    summary(total: total, count: visible.count)
                        .padding(.top, DS.CategoryManagement.sectionSpacing)

                    if visible.isEmpty {
                        Text(scope.emptyMessage)
                            .font(DS.Font.bodySmall)
                            .foregroundStyle(DS.Color.ink2)
                            .multilineTextAlignment(.center)
                            .padding(.top, DS.Spacing.xl)
                    } else {
                        ForEach(TransactionSection.group(visible)) { section in
                            TransactionDaySection(
                                section: section,
                                onTap: { editingTransaction = $0 },
                                onDuplicate: { duplicatedTransaction = $0 },
                                onDelete: deletion.requestDeletion
                            )
                        }
                    }
                }
                .padding(.horizontal, DS.Spacing.xl)
                .padding(.bottom, DS.Spacing.lg)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(DS.Color.bg.ignoresSafeArea())
        .presentationDragIndicator(.hidden)
        .safeAreaInset(edge: .bottom, spacing: .zero) {
            if let undo = deletion.undoAction {
                UndoToast(message: undo.message) {
                    deletion.undoLastAction(using: repositories.transactions)
                }
                .id(undo.id)
                .padding(.horizontal, DS.Spacing.xl)
                .padding(.bottom, DS.Spacing.sm)
                .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sheet(item: $editingTransaction) { transaction in
            AddTransactionView(transaction: transaction, accountSelection: accountSelection) {
                deletion.deleteTransaction($0, using: repositories.transactions)
            }
        }
        .sheet(item: $duplicatedTransaction) { transaction in
            AddTransactionView(template: transaction, accountSelection: accountSelection)
        }
        .brutalAlert(
            isPresented: $deletion.showingDeleteConfirmation,
            title: AppString.deleteTransactionTitle,
            message: deletion.deletionMessage,
            confirmTitle: AppString.delete,
            onConfirm: { deletion.confirmDeletion(using: repositories.transactions) },
            onCancel: deletion.cancelDeletion
        )
        .saveErrorAlert(isPresented: $deletion.showingSaveError)
    }

    private var header: some View {
        HStack(spacing: DS.Spacing.sm) {
            IconButton(icon: DS.Icon.chevronLeft, accessibilityLabel: AppString.categoryBack) { dismiss() }
                .accessibilityIdentifier(AccessibilityID.categoryTransactionsBack)
            Text(category.name)
                .font(DS.Font.dialogTitle)
                .foregroundStyle(DS.Color.ink)
                .lineLimit(1)
                .minimumScaleFactor(DS.CategoryManagement.minimumScale)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)
            Color.clear.frame(width: DS.Size.control, height: DS.Size.control).accessibilityHidden(true)
        }
    }

    private func summary(total: Decimal, count: Int) -> some View {
        let color = DS.CategoryColor(legacyHex: category.colorHex)
        var details = [AppString.categoryOperationCount(count)]
        if let limit = scope.budget(in: category.budgetPlans) {
            details.append(AppString.categoryBudgetAmount(MoneyFormat.money(limit)))
            if let percent = CategoryTransactionsScope.budgetPercent(total: total, limit: limit) {
                details.append(AppString.budgetsPercent(percent))
            }
        }

        return VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Text(scope.totalTitle).dsLabel(color: color.foreground)
            Text(MoneyFormat.money(total))
                .font(DS.Font.amountL)
                .lineLimit(1)
                .minimumScaleFactor(DS.CategoryManagement.minimumScale)
            Text(details.joined(separator: AppString.titleSeparator))
                .font(DS.Font.moneySmall)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(color.foreground)
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.vertical, DS.CategoryManagement.sectionSpacing)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.color, in: RoundedRectangle(cornerRadius: DS.Radius.card))
        .brutalBorder(radius: DS.Radius.card)
        .hardShadow()
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(AccessibilityID.categoryTransactionsSummary)
    }
}

#if DEBUG
#Preview("Данные") { categoryTransactionsPreview() }
#Preview("Данные · тёмная") { categoryTransactionsPreview().preferredColorScheme(.dark) }
#Preview("Пусто") { categoryTransactionsPreview(empty: true) }
#Preview("Пусто · тёмная") { categoryTransactionsPreview(empty: true).preferredColorScheme(.dark) }

@MainActor
private func categoryTransactionsPreview(empty: Bool = false) -> some View {
    let fixture = FixtureEnvironment(.empty)
    let category = Category(name: "Еда", icon: "cup.and.saucer", colorHex: "#8EE3A1")
    fixture.context.insert(category)
    fixture.context.insert(BudgetPlan(category: category, monthlyLimit: 60_000))

    let calendar = Calendar.current
    let date = calendar.date(from: DateComponents(year: 2026, month: 11, day: 20)) ?? .now
    if !empty {
        for (daysAgo, amount, note) in [(0, 4_850, "Продукты на неделю"), (1, 3_200, "Обед в кафе"), (5, 12_600, "Супермаркет")] {
            fixture.context.insert(Transaction(
                amount: Decimal(amount), date: calendar.date(byAdding: .day, value: -daysAgo, to: date) ?? date,
                note: note, type: .expense, category: category
            ))
        }
    }

    let interval = calendar.dateInterval(of: .month, for: date) ?? DateInterval(start: date, duration: 0)
    return CategoryTransactionsView(
        category: category,
        scope: CategoryTransactionsScope(period: .month, interval: interval, title: "Ноябрь", type: .expense)
    )
    .fixture(fixture)
}
#endif

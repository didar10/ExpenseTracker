//
//  TransactionDaySection.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftData
import SwiftUI

/// День ленты главной: метка «Сегодня» и итог дня, под ними карточка-список операций
/// с серыми разделителями. Тап открывает операцию, удержание — меню «Изменить / Дублировать / Удалить»
struct TransactionDaySection: View {

    // MARK: - Properties

    let section: TransactionSection
    /// Счет фильтра ленты: переводы в нем показываются со знаком. nil — «Все счета»
    var account: Account?
    let onTap: (Transaction) -> Void
    let onDuplicate: (Transaction) -> Void
    let onDelete: (Transaction) -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            header

            Card(padding: nil) {
                VStack(spacing: .zero) {
                    ForEach(Array(section.transactions.enumerated()), id: \.element.id) { index, transaction in
                        if index > .zero {
                            ListDivider()
                        }

                        DashboardTransactionRow(
                            transaction: transaction,
                            account: account,
                            onTap: { onTap(transaction) },
                            onDuplicate: { onDuplicate(transaction) },
                            onDelete: { onDelete(transaction) }
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Subviews

private extension TransactionDaySection {

    var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(DayTitle.text(for: section.date))
                .dsLabel()
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: DS.Spacing.sm)

            Text(MoneyFormat.signed(section.total))
                .font(DS.Font.moneySmall)
                .foregroundStyle(DS.Color.ink2)
                .accessibilityLabel("\(MoneyFormat.signed(section.total)) \(AppString.currencySymbol)")
        }
        .padding(.horizontal, Metrics.headerInset)
        .padding(.top, Metrics.headerTop)
        .padding(.bottom, DS.Spacing.sm)
    }
}

// MARK: - Row

/// Строка операции с меню по удержанию; меню поднимает строку над затемнением, как в `TxContextMenu.png`
private struct DashboardTransactionRow: View {

    // MARK: - Properties

    let transaction: Transaction
    let account: Account?
    let onTap: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void

    @State private var isMenuShown = false

    // MARK: - Body

    var body: some View {
        let model = TransactionRowModel(transaction, account: account)

        TransactionRow(
            title: model.title,
            subtitle: model.subtitle,
            amount: model.amount,
            tone: model.tone,
            icon: model.icon,
            color: model.color
        )
        .background(DS.Color.surface)
        // Тап и удержание — жестами, а не кнопкой: удержание не должно открывать операцию
        .onTapGesture(perform: onTap)
        .onLongPressGesture { isMenuShown = true }
        .sensoryFeedback(.impact(weight: .medium), trigger: isMenuShown) { _, isShown in isShown }
        .brutalMenu(isPresented: $isMenuShown, items: menuItems, liftsSource: true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(model.accessibilityLabel)
        .accessibilityHint(AppString.editTransactionHint)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { onTap() }
        .accessibilityAction(named: AppString.duplicateTransaction, onDuplicate)
        .accessibilityAction(named: AppString.delete, onDelete)
    }

    // MARK: - Private

    private var menuItems: [BrutalMenuItem] {
        [
            BrutalMenuItem(title: AppString.edit, icon: AppImage.pencil, action: onTap),
            BrutalMenuItem(title: AppString.duplicateTransaction, icon: AppImage.duplicate, action: onDuplicate),
            BrutalMenuItem(title: AppString.delete, icon: AppImage.trash, role: .destructive, action: onDelete)
        ]
    }
}

// MARK: - Day Title

/// «Сегодня», «Вчера», «Ср, 18 ноября». Регистр задает метка
enum DayTitle {

    /// Формат по локали устройства, один на всю ленту: DateFormatter дорого создавать на строку
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEdMMMM")
        return formatter
    }()

    static func text(for date: Date, calendar: Calendar = .current) -> String {
        if calendar.isDateInToday(date) { return AppString.today }
        if calendar.isDateInYesterday(date) { return AppString.yesterday }
        return formatter.string(from: date)
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/Main.html` (.dayh)
    static let headerTop: CGFloat = 22
    static let headerInset: CGFloat = 2
}

// MARK: - Previews

#if DEBUG
private struct TransactionDaySectionPreview: View {

    let fixture: Fixture
    /// Лента одного счета: переводы со знаком
    var filtersByAccount = false

    var body: some View {
        let environment = FixtureEnvironment(fixture)
        let all = (try? environment.context.fetch(FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date, order: .reverse)]))) ?? []
        let account = filtersByAccount ? all.first { $0.kind == .transfer }?.fromAccount : nil
        let transactions = account.map { account in all.filter { $0.involves(account) } } ?? all
        // Дни с переводом — первыми, чтобы превью их показывало
        let grouped = TransactionSection.group(transactions)
        let hasTransfer: (TransactionSection) -> Bool = { $0.transactions.contains { $0.kind == .transfer } }
        let sections = (grouped.filter(hasTransfer) + grouped.filter { !hasTransfer($0) }).prefix(2)

        ScrollView {
            VStack(spacing: .zero) {
                ForEach(Array(sections)) { section in
                    TransactionDaySection(
                        section: section,
                        account: account,
                        onTap: { _ in },
                        onDuplicate: { _ in },
                        onDelete: { _ in }
                    )
                }
            }
            .padding(.horizontal, DS.Spacing.xl)
        }
        .background(DS.Color.bg)
        .fixture(environment)
    }
}

#Preview("Данные · светлая") {
    TransactionDaySectionPreview(fixture: .sample)
}

#Preview("Данные · темная") {
    TransactionDaySectionPreview(fixture: .sample)
        .preferredColorScheme(.dark)
}

#Preview("Один счет: переводы со знаком · светлая") {
    TransactionDaySectionPreview(fixture: .sample, filtersByAccount: true)
}

#Preview("Один счет: переводы со знаком · темная") {
    TransactionDaySectionPreview(fixture: .sample, filtersByAccount: true)
        .preferredColorScheme(.dark)
}
#endif

//
//  AccountPickerSheetContent.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftData
import SwiftUI

/// Содержимое листа «Счёт»: список счетов с балансом, выбранный — на accent с галочкой.
/// Под списком — «+ Новый счёт». Выбор сразу закрывает лист.
/// В переводе счет другой стороны недоступен и помечен «Списание» / «Зачисление»
struct AccountPickerSheetContent: View {

    // MARK: - Properties

    let selectedAccount: Account?
    /// Счет, который нельзя выбрать, и метка вместо галочки
    var disabledAccount: Account?
    var disabledTag: String?
    let onSelect: (Account) -> Void

    // MARK: - Init

    init(
        selectedAccount: Account?,
        disabledAccount: Account? = nil,
        disabledTag: String? = nil,
        onSelect: @escaping (Account) -> Void
    ) {
        self.selectedAccount = selectedAccount
        self.disabledAccount = disabledAccount
        self.disabledTag = disabledTag
        self.onSelect = onSelect
    }

    /// Список читается своим запросом: после удаления счета родитель мог бы отдать
    /// снимок с невалидной моделью
    @Query(sort: [SortDescriptor(\Account.sortOrder), SortDescriptor(\Account.createdAt)])
    private var accounts: [Account]

    @State private var showingNewAccount = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.md) {
                if !accounts.isEmpty {
                    AccountPickerList(
                        rows: accounts.filter(\.isAvailable).map(makeRow),
                        selectedID: selectedAccount?.persistentModelID
                    ) { id in
                        guard let account = accounts.first(where: { $0.persistentModelID == id }) else { return }
                        onSelect(account)
                    }
                }

                newAccountButton
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .sheet(isPresented: $showingNewAccount) {
            AccountFormView()
        }
    }
}

// MARK: - Subviews

private extension AccountPickerSheetContent {

    func makeRow(_ account: Account) -> AccountPickerRow {
        let isDisabled = account.persistentModelID == disabledAccount?.persistentModelID
        return AccountPickerRow(account, disabledTag: isDisabled ? disabledTag ?? "" : nil)
    }

    var newAccountButton: some View {
        Button {
            showingNewAccount = true
        } label: {
            Text(AppString.newAccountButton)
                .font(DS.Font.body)
                .frame(maxWidth: .infinity, minHeight: Metrics.newAccountHeight)
                .overlay {
                    RoundedRectangle(cornerRadius: DS.Radius.control)
                        .strokeBorder(DS.Color.ink, style: StrokeStyle(lineWidth: DS.Stroke.regular, dash: DS.Stroke.dash))
                }
        }
        .buttonStyle(OutlineClickStyle(shape: .bordered(radius: DS.Radius.control), fill: DS.Color.bg))
    }
}

// MARK: - Row

/// Строка списка без SwiftData — для превью и снапшотов
struct AccountPickerRow: Identifiable {
    let id: PersistentIdentifier?
    let title: String
    let balance: String
    let icon: Image
    let color: Color
    /// Не nil — строка недоступна, справа метка: «Списание» на листе «Куда»
    var disabledTag: String?

    var isDisabled: Bool {
        disabledTag != nil
    }

    init(id: PersistentIdentifier?, title: String, balance: String, icon: Image, color: Color, disabledTag: String? = nil) {
        self.id = id
        self.title = title
        self.balance = balance
        self.icon = icon
        self.color = color
        self.disabledTag = disabledTag
    }

    init(_ account: Account, disabledTag: String? = nil) {
        self.init(
            id: account.persistentModelID,
            title: account.name,
            balance: MoneyFormat.money(account.currentBalance),
            icon: Image(systemName: account.icon),
            color: DS.accountColor(named: account.color),
            disabledTag: disabledTag
        )
    }
}

/// Карточка-список счетов
struct AccountPickerList: View {

    // MARK: - Properties

    let rows: [AccountPickerRow]
    let selectedID: PersistentIdentifier?
    let onSelect: (PersistentIdentifier?) -> Void

    // MARK: - Body

    var body: some View {
        Card(padding: nil) {
            VStack(spacing: .zero) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    if index > .zero {
                        ListDivider()
                    }
                    rowView(row)
                }
            }
        }
    }

    private func rowView(_ row: AccountPickerRow) -> some View {
        let isSelected = row.id != nil && row.id == selectedID

        return Button {
            onSelect(row.id)
        } label: {
            HStack(spacing: DS.Spacing.md) {
                row.icon
                    .font(.system(size: DS.Size.iconM, weight: .semibold))
                    .foregroundStyle(DS.Color.onColorFill)
                    .frame(width: Metrics.cardWidth, height: Metrics.cardHeight)
                    .background(row.color, in: RoundedRectangle(cornerRadius: Metrics.cardRadius))
                    .brutalBorder(radius: Metrics.cardRadius)

                VStack(alignment: .leading, spacing: .zero) {
                    Text(row.title)
                        .font(DS.Font.bodyBold)
                        .lineLimit(1)
                    Text(row.balance)
                        .font(DS.Font.moneySmall)
                        .foregroundStyle(isSelected ? DS.Color.onAccent : DS.Color.ink2)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if let tag = row.disabledTag {
                    disabledTagView(tag)
                } else {
                    checkCircle(isSelected: isSelected)
                }
            }
            .padding(.leading, Metrics.leadingPadding)
            .padding(.trailing, Metrics.trailingPadding)
            .frame(minHeight: DS.Size.row)
            .background(isSelected ? DS.Color.accent : .clear)
            .foregroundStyle(isSelected ? DS.Color.onAccent : DS.Color.ink)
            .contentShape(Rectangle())
            .opacity(row.isDisabled ? Metrics.disabledOpacity : 1)
        }
        .buttonStyle(.outlineClickSegment)
        .disabled(row.isDisabled)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel([row.title, row.balance, row.disabledTag].compactMap { $0 }.joined(separator: ", "))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    /// Метка недоступного счета: `AddTransferPickTo.html` (.acc .tag)
    private func disabledTagView(_ tag: String) -> some View {
        Text(tag)
            .dsLabel(font: DS.Font.labelSmall)
            .lineLimit(1)
            .padding(.horizontal, Metrics.tagHorizontalPadding)
            .padding(.vertical, Metrics.tagVerticalPadding)
            .overlay {
                RoundedRectangle(cornerRadius: Metrics.tagRadius)
                    .strokeBorder(DS.Color.line, lineWidth: DS.Stroke.hairline)
            }
    }

    private func checkCircle(isSelected: Bool) -> some View {
        Circle()
            .fill(isSelected ? DS.Color.onAccent : DS.Color.surface)
            .overlay {
                Circle().strokeBorder(DS.Color.ink, lineWidth: DS.Stroke.regular)
            }
            .overlay {
                if isSelected {
                    DS.Icon.checkmark
                        .font(.system(size: DS.Size.iconXS, weight: .bold))
                        .foregroundStyle(DS.Color.accent)
                }
            }
            .frame(width: Metrics.check, height: Metrics.check)
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/AccountPicker.html` (.acc, .cd, .chk)
    static let cardWidth: CGFloat = 46
    static let cardHeight: CGFloat = 32
    static let cardRadius: CGFloat = 7
    static let check: CGFloat = 26
    static let leadingPadding: CGFloat = 10
    static let trailingPadding: CGFloat = 14
    static let newAccountHeight: CGFloat = 46
    /// `AddTransferPickTo.html` (.acc[disabled], .acc .tag)
    static let disabledOpacity: CGFloat = 0.45
    static let tagHorizontalPadding: CGFloat = 6
    static let tagVerticalPadding: CGFloat = 3
    static let tagRadius: CGFloat = 6
}

// MARK: - Previews

#if DEBUG
private enum AccountPickerPreviewData {
    static let rows = [
        AccountPickerRow(id: nil, title: "Freedom", balance: "49 300 ₸", icon: Image(systemName: "creditcard"), color: DS.CategoryColor.green.color),
        AccountPickerRow(id: nil, title: "Kaspi Gold", balance: "78 300 ₸", icon: Image(systemName: "building.columns"), color: DS.CategoryColor.blue.color),
        AccountPickerRow(id: nil, title: "Наличные", balance: "12 000 ₸", icon: Image(systemName: "banknote"), color: DS.CategoryColor.orange.color)
    ]

    /// Лист «Куда»: счет списания недоступен
    static let transferRows = [
        rows[0],
        AccountPickerRow(id: nil, title: "Kaspi Gold", balance: "78 300 ₸", icon: Image(systemName: "building.columns"),
                         color: DS.CategoryColor.blue.color, disabledTag: "Списание"),
        rows[2]
    ]
}

#Preview("Данные · светлая") {
    AccountPickerSheetContent(selectedAccount: nil) { _ in }
        .padding(DS.Spacing.xl)
        .background(DS.Color.bg)
        .fixture(FixtureEnvironment(.sample))
}

#Preview("Данные · темная") {
    AccountPickerSheetContent(selectedAccount: nil) { _ in }
        .padding(DS.Spacing.xl)
        .background(DS.Color.bg)
        .fixture(FixtureEnvironment(.sample))
        .preferredColorScheme(.dark)
}

#Preview("Пусто") {
    AccountPickerSheetContent(selectedAccount: nil) { _ in }
        .padding(DS.Spacing.xl)
        .background(DS.Color.bg)
        .fixture(FixtureEnvironment(.empty))
}

#Preview("Список без данных") {
    AccountPickerList(rows: AccountPickerPreviewData.rows, selectedID: nil) { _ in }
        .padding(DS.Spacing.xl)
        .background(DS.Color.bg)
}

#Preview("Перевод: счет списания недоступен · светлая") {
    AccountPickerList(rows: AccountPickerPreviewData.transferRows, selectedID: nil) { _ in }
        .padding(DS.Spacing.xl)
        .background(DS.Color.bg)
}

#Preview("Перевод: счет списания недоступен · темная") {
    AccountPickerList(rows: AccountPickerPreviewData.transferRows, selectedID: nil) { _ in }
        .padding(DS.Spacing.xl)
        .background(DS.Color.bg)
        .preferredColorScheme(.dark)
}
#endif

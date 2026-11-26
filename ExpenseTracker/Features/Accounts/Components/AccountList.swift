import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// Снимок строки: список не обращается к связям уже удаленной SwiftData-модели.
struct AccountListItem: Identifiable {
    let id: PersistentIdentifier?
    let title: String
    let balance: String
    let icon: Image
    let color: Color
    let iconColor: Color
    var isDefault = false

    init(_ account: Account) {
        id = account.persistentModelID
        title = account.name
        balance = MoneyFormat.money(account.currentBalance)
        icon = Image(systemName: account.icon)
        color = DS.accountColor(named: account.color)
        iconColor = DS.AccountColor(name: account.color).foreground
        isDefault = account.isDefault
    }

    init(totalBalance: Decimal) {
        id = nil
        title = AppString.allAccounts
        balance = MoneyFormat.money(totalBalance)
        icon = AppImage.allAccounts
        color = DS.Color.ink
        iconColor = DS.Color.bg
    }
}

/// Общая карточка для выбора счета на главной, в статистике и управления в настройках.
/// В режиме правки перетаскивание начинается за ручку; «Все счета» всегда неподвижно.
struct AccountList: View {
    let items: [AccountListItem]
    var selectedID: PersistentIdentifier?
    var isEditing = false
    var showsSelection = true
    let onSelect: (PersistentIdentifier?) -> Void
    var onDelete: (PersistentIdentifier) -> Void = { _ in }
    var onMove: (PersistentIdentifier, PersistentIdentifier) -> Void = { _, _ in }

    var body: some View {
        Card(padding: nil) {
            VStack(spacing: .zero) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    if index > 0 { ListDivider() }
                    row(item)
                }
            }
        }
    }

    private func row(_ item: AccountListItem) -> some View {
        let selected = showsSelection && !isEditing && item.id == selectedID
        return HStack(spacing: DS.Spacing.sm) {
            if isEditing, let id = item.id {
                deleteButton(id: id, title: item.title)
            }
            Button { onSelect(item.id) } label: {
                HStack(spacing: DS.Spacing.md) {
                    item.icon
                        .font(.system(size: DS.Size.iconS, weight: .semibold))
                        .foregroundStyle(item.iconColor)
                        .frame(width: DS.AccountList.iconWidth, height: DS.AccountList.iconHeight)
                        .background(item.color, in: RoundedRectangle(cornerRadius: DS.AccountList.iconRadius))
                        .brutalBorder(radius: DS.AccountList.iconRadius)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: DS.Spacing.sm) {
                                title(item)
                                if item.isDefault { DefaultAccountBadge() }
                            }
                            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                                title(item)
                                if item.isDefault { DefaultAccountBadge() }
                            }
                        }
                        Text(item.balance)
                            .font(DS.Font.moneySmall)
                            .foregroundStyle(selected ? DS.Color.onAccent : DS.Color.ink2)
                            .lineLimit(1)
                            .minimumScaleFactor(DS.AccountList.minimumScale)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    if selected {
                        DS.Icon.checkmark
                            .font(.system(size: DS.Size.iconM, weight: .bold))
                            .accessibilityHidden(true)
                    }
                }
                .padding(.vertical, DS.Spacing.sm)
                .frame(maxWidth: .infinity, minHeight: DS.AccountList.rowHeight, alignment: .leading)
                .foregroundStyle(selected ? DS.Color.onAccent : DS.Color.ink)
                .contentShape(Rectangle())
            }
            // Вне правки строка — одна кнопка: щелчок подсвечивает ее вместе с отступами
            .buttonStyle(.outlineClickRow(bleed: isEditing ? EdgeInsets() : rowBleed))
            .allowsHitTesting(!isEditing || item.id != nil)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(selected ? .isSelected : [])
            .accessibilityHint(isEditing && item.id != nil ? AppString.editAccount : "")

            if isEditing, let id = item.id {
                DS.Icon.equal
                    .font(.system(size: DS.Size.iconM, weight: .semibold))
                    .frame(width: DS.Size.control, height: DS.Size.control)
                    .contentShape(Rectangle())
                    .draggable(AccountDrag(id: id))
                    .accessibilityLabel(AppString.reorderAccount(item.title))
                    .accessibilityAction(named: AppString.moveAccountUp) { move(id, by: -1) }
                    .accessibilityAction(named: AppString.moveAccountDown) { move(id, by: 1) }
            }
        }
        .padding(.leading, DS.Spacing.md)
        .padding(.trailing, DS.AccountList.trailingPadding)
        .background(selected ? DS.Color.accent : DS.Color.surface)
        .foregroundStyle(selected ? DS.Color.onAccent : DS.Color.ink)
        .dropDestination(for: AccountDrag.self) { dragged, _ in
            guard isEditing, let target = item.id, let source = dragged.first?.id,
                  items.contains(where: { $0.id == source }), source != target else { return false }
            onMove(source, target)
            return true
        }
    }

    private var rowBleed: EdgeInsets {
        EdgeInsets(top: .zero, leading: DS.Spacing.md, bottom: .zero, trailing: DS.AccountList.trailingPadding)
    }

    private func title(_ item: AccountListItem) -> some View {
        Text(item.title)
            .font(DS.Font.bodyBold)
            .lineLimit(1)
    }

    private func deleteButton(id: PersistentIdentifier, title: String) -> some View {
        Button { onDelete(id) } label: {
            DS.Icon.minus
                .font(.system(size: DS.Size.iconXS, weight: .bold))
                .frame(width: DS.AccountList.deleteSize, height: DS.AccountList.deleteSize)
                .frame(minHeight: DS.Size.control)
        }
        .buttonStyle(.outlineClickDelete(diameter: DS.AccountList.deleteSize, fill: DS.Color.overStripeSoft))
        .accessibilityLabel(AppString.deleteNamedAccount(title))
    }

    private func move(_ id: PersistentIdentifier, by offset: Int) {
        let ids = items.compactMap(\.id)
        guard let index = ids.firstIndex(of: id), ids.indices.contains(index + offset) else { return }
        onMove(id, ids[index + offset])
    }
}

private struct DefaultAccountBadge: View {
    @ScaledMetric(relativeTo: .caption2) private var fontSize = DS.AccountList.badgeFont

    var body: some View {
        Text(AppString.defaultAccountBadge)
            .font(.system(size: fontSize))
            .foregroundStyle(DS.Color.ink2)
            .padding(.horizontal, DS.Spacing.sm)
            .frame(minHeight: DS.AccountList.badgeHeight)
            .background(DS.Color.surface, in: RoundedRectangle(cornerRadius: DS.AccountList.iconRadius))
            .brutalBorder(radius: DS.AccountList.iconRadius)
            .fixedSize()
            .accessibilityLabel(AppString.defaultAccount)
    }
}

#if DEBUG
#Preview("Список · светлая") {
    let environment = FixtureEnvironment(.sample)
    let accounts = (try? environment.context.fetch(FetchDescriptor<Account>())) ?? []
    AccountList(items: [AccountListItem(totalBalance: 975_050)] + accounts.map(AccountListItem.init), onSelect: { _ in })
        .padding(DS.Spacing.xl)
        .background(DS.Color.bg)
}
#Preview("Список · темная") {
    let environment = FixtureEnvironment(.sample)
    let accounts = (try? environment.context.fetch(FetchDescriptor<Account>())) ?? []
    AccountList(items: accounts.map(AccountListItem.init), isEditing: true, onSelect: { _ in })
        .padding(DS.Spacing.xl)
        .background(DS.Color.bg)
        .preferredColorScheme(.dark)
}
#endif

/// Отдельный тип переноса: чужой текст нельзя принять за перетаскивание счета.
private struct AccountDrag: Codable, Transferable {
    let id: PersistentIdentifier
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .accountReorder)
    }
}

private extension UTType {
    static let accountReorder = UTType(exportedAs: "com.expensetracker.account-reorder", conformingTo: .data)
}

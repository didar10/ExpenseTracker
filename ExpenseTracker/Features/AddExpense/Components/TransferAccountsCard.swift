//
//  TransferAccountsCard.swift
//  ExpenseTracker
//
//  Created by Didar on 26.11.2026.
//

import SwiftUI

/// Карточка перевода «Откуда / Куда» вместо пилюли счета и ленты категорий:
/// две строки 62 pt со счетом и балансом «до → после», на стыке строк — желтая ⇄.
/// Баланс списания уходит в минус — красная обводка (сохранение при этом не блокируется)
struct TransferAccountsCard: View {

    // MARK: - Types

    /// Строка без SwiftData — для превью
    struct Row {
        let name: String
        let icon: Image
        let color: Color
        /// «78 300 ₸»
        let balance: String
        /// «28 300 ₸»; nil — суммы еще нет
        let balanceAfter: String?
        var isNegativeAfter = false
    }

    // MARK: - Properties

    /// nil — счет не выбран: пунктирная плашка «+» и «Выберите счёт»
    let from: Row?
    let to: Row?
    var isOverdrawn = false
    let onSelectFrom: () -> Void
    let onSelectTo: () -> Void
    let onSwap: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            rowButton(label: AppString.transferFrom, row: from, action: onSelectFrom)
            ListDivider()
            rowButton(label: AppString.transferTo, row: to, action: onSelectTo)
        }
        .background(DS.Color.surface, in: RoundedRectangle(cornerRadius: DS.Radius.card))
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card))
        .brutalBorder(radius: DS.Radius.card, color: isOverdrawn ? DS.Color.danger : DS.Color.ink)
        .overlay(alignment: .trailing) {
            swapButton
                .padding(.trailing, Metrics.swapInset)
        }
    }
}

// MARK: - Subviews

private extension TransferAccountsCard {

    func rowButton(label: String, row: Row?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.md) {
                Text(label)
                    .dsLabel()
                    .lineLimit(1)
                    .minimumScaleFactor(Metrics.labelMinimumScale)
                    .frame(width: Metrics.labelWidth, alignment: .leading)

                if let row {
                    accountChip(row)
                    accountText(row)
                } else {
                    placeholderChip
                    Text(AppString.transferChooseAccount)
                        .font(DS.Font.body.weight(.medium))
                        .foregroundStyle(DS.Color.ink2)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            // Справа место под ⇄
            .padding(.trailing, Metrics.swapReserve)
            .padding(.leading, Metrics.leadingPadding)
            .frame(maxWidth: .infinity, minHeight: Metrics.rowHeight, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.outlineClickSegment)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel(label: label, row: row))
        .accessibilityHint(AppString.dsChooseAccountHint)
    }

    func accountChip(_ row: Row) -> some View {
        row.icon
            .font(.system(size: DS.Size.iconS, weight: .semibold))
            .foregroundStyle(DS.Color.onColorFill)
            .frame(width: Metrics.chipWidth, height: Metrics.chipHeight)
            .background(row.color, in: RoundedRectangle(cornerRadius: Metrics.chipRadius))
            .brutalBorder(radius: Metrics.chipRadius)
    }

    var placeholderChip: some View {
        DS.Icon.plus
            .font(.system(size: DS.Size.iconS, weight: .semibold))
            .foregroundStyle(DS.Color.ink2)
            .frame(width: Metrics.chipWidth, height: Metrics.chipHeight)
            .background(DS.Color.bg, in: RoundedRectangle(cornerRadius: Metrics.chipRadius))
            .overlay {
                RoundedRectangle(cornerRadius: Metrics.chipRadius)
                    .strokeBorder(DS.Color.ink, style: StrokeStyle(lineWidth: DS.Stroke.regular, dash: DS.Stroke.dash))
            }
    }

    func accountText(_ row: Row) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text(row.name)
                .font(DS.Font.bodyBold)
                .foregroundStyle(DS.Color.ink)
                .lineLimit(1)

            balanceText(row)
                .font(DS.Font.moneySmall)
                .lineLimit(1)
                .minimumScaleFactor(Metrics.balanceMinimumScale)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// «78 300 ₸ → 28 300 ₸»: текущий баланс серым, итоговый — ink или красным при минусе
    func balanceText(_ row: Row) -> Text {
        let current = Text(row.balance).foregroundStyle(DS.Color.ink2)
        guard let after = row.balanceAfter else { return current }

        let arrow = Text(Constants.arrow).foregroundStyle(DS.Color.ink2)
        let result = Text(after).foregroundStyle(row.isNegativeAfter ? DS.Color.danger : DS.Color.ink)
        return Text("\(current)\(arrow)\(result)")
    }

    var swapButton: some View {
        Button(action: onSwap) {
            DS.Icon.transfer
                .font(.system(size: DS.Size.iconM, weight: .bold))
                .frame(width: Metrics.swapSize, height: Metrics.swapSize)
        }
        .buttonStyle(PressIntoShadowStyle(variant: .primary, radius: Metrics.swapRadius))
        .frame(width: Metrics.swapSize, height: Metrics.swapSize)
        .accessibilityLabel(AppString.transferSwap)
    }

    func accessibilityLabel(label: String, row: Row?) -> String {
        guard let row else { return "\(label), \(AppString.transferChooseAccount)" }
        guard let after = row.balanceAfter else { return "\(label), \(row.name), \(row.balance)" }

        return "\(label), \(row.name), \(AppString.transferBalanceChange(current: row.balance, after: after))"
    }
}

// MARK: - Constants

private enum Constants {
    static let arrow = " → "
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/AddTransferFilled.html` (.tr, .ar, .k, .cd, .swap)
    static let rowHeight: CGFloat = 62
    static let leadingPadding: CGFloat = 10
    static let labelWidth: CGFloat = 52
    static let labelMinimumScale: CGFloat = 0.8
    static let chipWidth: CGFloat = 40
    static let chipHeight: CGFloat = 28
    static let chipRadius: CGFloat = 7
    static let balanceMinimumScale: CGFloat = 0.8
    static let swapSize: CGFloat = 36
    static let swapRadius: CGFloat = 10
    static let swapInset: CGFloat = 12
    /// Отступ текста справа: ⇄ 36 + зазор 8 (.t padding-right 44) + отступ строки 12
    static let swapReserve: CGFloat = 56
}

// MARK: - Previews

#if DEBUG
private enum TransferCardPreviewData {
    static let kaspi = TransferAccountsCard.Row(
        name: "Kaspi Gold", icon: Image(systemName: "building.columns"), color: DS.CategoryColor.blue.color,
        balance: "78 300 ₸", balanceAfter: "28 300 ₸"
    )
    static let cash = TransferAccountsCard.Row(
        name: "Наличные", icon: Image(systemName: "banknote"), color: DS.CategoryColor.orange.color,
        balance: "12 000 ₸", balanceAfter: "62 000 ₸"
    )
    static let freedom = TransferAccountsCard.Row(
        name: "Freedom", icon: Image(systemName: "wallet.bifold"), color: DS.CategoryColor.green.color,
        balance: "49 300 ₸", balanceAfter: nil
    )
    static let cashOverdrawn = TransferAccountsCard.Row(
        name: "Наличные", icon: Image(systemName: "banknote"), color: DS.CategoryColor.orange.color,
        balance: "12 000 ₸", balanceAfter: "−38 000 ₸", isNegativeAfter: true
    )
    static let kaspiIncoming = TransferAccountsCard.Row(
        name: "Kaspi Gold", icon: Image(systemName: "building.columns"), color: DS.CategoryColor.blue.color,
        balance: "78 300 ₸", balanceAfter: "128 300 ₸"
    )
}

private struct TransferAccountsCardGallery: View {

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Пусто: «Куда» не выбран") {
                TransferAccountsCard(from: TransferCardPreviewData.freedom, to: nil,
                                     onSelectFrom: {}, onSelectTo: {}, onSwap: {})
            }
            DSPreviewCase("Заполнено") {
                TransferAccountsCard(from: TransferCardPreviewData.kaspi, to: TransferCardPreviewData.cash,
                                     onSelectFrom: {}, onSelectTo: {}, onSwap: {})
            }
            DSPreviewCase("Ошибка: баланс в минус") {
                TransferAccountsCard(from: TransferCardPreviewData.cashOverdrawn, to: TransferCardPreviewData.kaspiIncoming,
                                     isOverdrawn: true, onSelectFrom: {}, onSelectTo: {}, onSwap: {})
            }
        }
    }
}

#Preview("Светлая") {
    TransferAccountsCardGallery()
}

#Preview("Темная") {
    TransferAccountsCardGallery()
        .preferredColorScheme(.dark)
}
#endif

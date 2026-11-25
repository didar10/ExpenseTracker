//
//  AccountPill.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Выбор счета в шапке главной: иконка на accent, название, баланс и шеврон
struct AccountPill: View {

    // MARK: - Properties

    let title: String
    /// Уже отформатированный баланс: «975 050 ₸»
    let balance: String
    let icon: Image
    /// Растянуть на всю доступную ширину, шеврон прижимается вправо
    var fillsWidth = false
    let action: () -> Void

    // MARK: - Init

    init(
        title: String,
        balance: String,
        icon: Image,
        fillsWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.balance = balance
        self.icon = icon
        self.fillsWidth = fillsWidth
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            content
        }
        .buttonStyle(.outlineClick)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(balance)")
        .accessibilityHint(AppString.dsChooseAccountHint)
    }
}

// MARK: - Subviews

extension AccountPill {

    /// Содержимое отдельно от кнопки — для превью нажатого состояния
    var content: some View {
        HStack(spacing: DS.Spacing.sm) {
            iconBadge

            VStack(alignment: .leading, spacing: .zero) {
                Text(title)
                    .font(DS.Font.control)
                    .lineLimit(1)

                Text(balance)
                    .font(DS.Font.moneySmall)
                    .foregroundStyle(DS.Color.ink2)
                    .lineLimit(1)
            }

            if fillsWidth {
                Spacer(minLength: DS.Spacing.xs)
            }

            DS.Icon.chevronDown
                .font(.system(size: DS.Size.iconS, weight: .bold))
        }
        .padding(.leading, DS.Spacing.sm)
        .padding(.trailing, Metrics.trailingPadding)
        .frame(minHeight: DS.Size.control)
        .frame(maxWidth: fillsWidth ? .infinity : nil, alignment: .leading)
    }

    private var iconBadge: some View {
        icon
            .font(.system(size: DS.Size.iconS, weight: .semibold))
            .foregroundStyle(DS.Color.onAccent)
            .frame(width: Metrics.badge, height: Metrics.badge)
            .background(DS.Color.accent, in: RoundedRectangle(cornerRadius: Metrics.badgeRadius))
            .brutalBorder(radius: Metrics.badgeRadius)
    }
}

// MARK: - Metrics

private extension AccountPill {

    /// Размеры из `Design/html/Main.html` (.pill, .dot)
    enum Metrics {
        static let badge: CGFloat = 28
        static let badgeRadius: CGFloat = 8
        static let trailingPadding: CGFloat = 14
    }
}

// MARK: - Previews

#if DEBUG
private struct AccountPillGallery: View {

    private let icon = Image(systemName: "wallet.bifold")

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Обычная") {
                AccountPill(title: "Все счета", balance: "975 050 ₸", icon: icon) {}
            }
            DSPreviewCase("Нажата") {
                OutlineClickBody(shape: .bordered(radius: DS.Radius.control), fill: DS.Color.surface, isPressed: true) {
                    AccountPill(title: "Все счета", balance: "975 050 ₸", icon: icon) {}.content
                }
                .fixedSize()
            }
            DSPreviewCase("Длинное название") {
                AccountPill(title: "Депозит на машину и отпуск", balance: "12 450 000 ₸", icon: icon) {}
                    .frame(maxWidth: 200)
            }
            DSPreviewCase("На всю ширину") {
                AccountPill(title: "Kaspi Gold", balance: "120 000 ₸", icon: icon, fillsWidth: true) {}
            }
        }
    }
}

#Preview("Светлая") {
    AccountPillGallery()
}

#Preview("Темная") {
    AccountPillGallery()
        .preferredColorScheme(.dark)
}
#endif

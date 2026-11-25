//
//  CategoryBudgetRow.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Строка бюджета категории: плитка, название, «потрачено / лимит», бейдж процента,
/// полоса с меткой темпа и остаток на день. Превышенный — красная штриховка и сумма превышения.
/// Удержание открывает меню с удалением
struct CategoryBudgetRow: View {

    // MARK: - Properties

    let item: CategoryBudgetItem
    let onDelete: () -> Void

    @State private var isMenuShown = false

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack(spacing: DS.Spacing.md) {
                CategoryTile(icon: item.icon, color: item.color, size: .medium)

                VStack(alignment: .leading, spacing: .zero) {
                    Text(item.name)
                        .font(DS.Font.bodyBold)
                        .foregroundStyle(DS.Color.ink)
                        .lineLimit(1)

                    Text(AppString.budgetsSpentOfLimit(MoneyFormat.number(item.spent), MoneyFormat.money(item.limit)))
                        .font(DS.Font.moneySmall)
                        .foregroundStyle(DS.Color.ink2)
                        .lineLimit(1)
                        .minimumScaleFactor(Metrics.amountMinimumScale)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                BudgetStatusBadge(status: item.status, percent: item.percent)
            }

            ProgressBar(progress: item.progress, tint: item.color.color, paceMarker: item.paceMarker)

            detail
        }
        .padding(.vertical, DS.Spacing.md)
        .padding(.horizontal, Metrics.horizontalPadding)
        .background(DS.Color.surface)
        .onLongPressGesture { isMenuShown = true }
        .sensoryFeedback(.impact(weight: .medium), trigger: isMenuShown) { _, isShown in isShown }
        .brutalMenu(isPresented: $isMenuShown, items: menuItems, liftsSource: true)
        .accessibilityElement(children: .combine)
        .accessibilityHint(AppString.budgetRowHint)
        .accessibilityAction(named: AppString.delete, onDelete)
    }
}

// MARK: - Subviews

private extension CategoryBudgetRow {

    @ViewBuilder
    var detail: some View {
        Group {
            if item.overspent > 0 {
                Text(AppString.budgetsExceededBy(MoneyFormat.money(item.overspent)))
                    .font(DS.Font.captionBold)
                    .foregroundStyle(DS.Color.danger)
            } else if item.status == .exceeded {
                Text(AppString.budgetsLimitUsedUp)
                    .font(DS.Font.captionBold)
                    .foregroundStyle(DS.Color.danger)
            } else if let perDay = item.perDay {
                Text(AppString.budgetsLeftPerDay(MoneyFormat.money(item.remaining), MoneyFormat.money(perDay)))
                    .font(DS.Font.caption)
                    .foregroundStyle(DS.Color.ink2)
            } else {
                Text(AppString.budgetsLeftAmount(MoneyFormat.money(item.remaining)))
                    .font(DS.Font.caption)
                    .foregroundStyle(DS.Color.ink2)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(Metrics.amountMinimumScale)
    }

    var menuItems: [BrutalMenuItem] {
        [BrutalMenuItem(title: AppString.delete, icon: AppImage.trash, role: .destructive, action: onDelete)]
    }
}

// MARK: - Status Badge

/// Бейдж процента: до 79% — белый, 80–99% — оранжевый, от 100% — красный «Превышен»
struct BudgetStatusBadge: View {

    // MARK: - Properties

    let status: CategoryBudgetItem.Status
    let percent: Int

    // MARK: - Body

    var body: some View {
        Text(title)
            .font(DS.Font.badge)
            .foregroundStyle(textColor)
            .lineLimit(1)
            .padding(.horizontal, DS.Spacing.sm)
            .frame(minHeight: Metrics.badgeHeight)
            .background(fill, in: RoundedRectangle(cornerRadius: Metrics.badgeRadius))
            .brutalBorder(radius: Metrics.badgeRadius)
            .fixedSize()
    }

    // MARK: - Private

    private var title: String {
        status == .exceeded ? AppString.budgetsBadgeExceeded : AppString.budgetsPercent(percent)
    }

    private var fill: Color {
        switch status {
        case .normal: return DS.Color.surface
        case .warning: return DS.CategoryColor.orange.color
        case .exceeded: return DS.Color.dangerFill
        }
    }

    private var textColor: Color {
        status == .exceeded ? DS.Color.onDanger : DS.Color.ink
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/Budgets.html` (.li, .st)
    static let horizontalPadding: CGFloat = 14
    static let badgeHeight: CGFloat = 24
    static let badgeRadius: CGFloat = 7
    static let amountMinimumScale: CGFloat = 0.8
}

// MARK: - Previews

#if DEBUG
private struct CategoryBudgetRowGallery: View {

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Список из макета") {
                Card(padding: nil) {
                    VStack(spacing: .zero) {
                        ForEach(Array(CategoryBudgetItem.previewItems.enumerated()), id: \.offset) { index, item in
                            if index > 0 { ListDivider() }
                            CategoryBudgetRow(item: item) {}
                        }
                    }
                }
            }
        }
    }
}

extension CategoryBudgetItem {

    /// Строки из `Budgets.html`: превышен, 81%, 46%, 34%
    @MainActor static var previewItems: [CategoryBudgetItem] {
        let rows: [(String, String, DS.CategoryColor, Decimal, Decimal)] = [
            ("Покупки", "bag", .orange, 28_500, 25_000),
            ("Дом", "house", .purple, 65_000, 80_000),
            ("Транспорт", "car", .blue, 9_300, 20_000),
            ("Еда", "cup.and.saucer", .green, 20_650, 60_000)
        ]
        let container = try? AppModelContainer.make(inMemory: true)

        return rows.compactMap { name, icon, color, spent, limit in
            guard let container else { return nil }
            let category = Category(name: name, icon: icon, colorHex: "#000000")
            container.mainContext.insert(category)
            let remaining = limit - spent

            return CategoryBudgetItem(
                id: category.persistentModelID,
                name: name,
                iconName: icon,
                color: color,
                spent: spent,
                limit: limit,
                perDay: remaining > 0 ? BudgetsViewModel.perDay(remaining, days: 11) : nil,
                paceMarker: 0.633
            )
        }
    }
}

#Preview("Светлая") {
    CategoryBudgetRowGallery()
}

#Preview("Темная") {
    CategoryBudgetRowGallery()
        .preferredColorScheme(.dark)
}
#endif

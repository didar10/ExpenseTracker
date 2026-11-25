//
//  DashboardBalanceView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Баланс главной: метка «На счетах», сумма и карточки «Доходы / Расходы» за период
struct DashboardBalanceView: View {

    // MARK: - Properties

    /// «На счетах» или «Баланс за всё время»
    let title: String
    let balance: Decimal
    let income: Decimal
    let expenses: Decimal
    /// false — операций еще нет: карточек доходов и расходов нет, как в `MainEmpty.html`
    var showsFlows = true
    let onIncomeTap: () -> Void
    let onExpenseTap: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text(title)
                .dsLabel()

            Text(MoneyFormat.money(balance))
                .font(DS.Font.amountL)
                .foregroundStyle(DS.Color.ink)
                .lineLimit(1)
                .minimumScaleFactor(Metrics.minimumScale)
                .contentTransition(.numericText())
                .padding(.top, Metrics.balanceTop)

            if showsFlows {
                flows
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var flows: some View {
        HStack(spacing: DS.Spacing.sm) {
            FlowCard(
                title: AppString.incomes,
                amount: MoneyFormat.signed(income),
                isIncome: true,
                icon: AppImage.incomeDirection,
                color: .green,
                action: onIncomeTap
            )

            FlowCard(
                title: AppString.expenses,
                amount: MoneyFormat.signed(-expenses),
                isIncome: false,
                icon: AppImage.expenseDirection,
                color: .orange,
                action: onExpenseTap
            )
        }
        .padding(.top, DS.Spacing.md)
    }
}

// MARK: - Flow Card

/// Карточка «Доходы +540 000»: плитка со стрелкой, метка и сумма
private struct FlowCard: View {

    // MARK: - Properties

    let title: String
    let amount: String
    let isIncome: Bool
    let icon: Image
    let color: DS.CategoryColor
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: Metrics.flowSpacing) {
                CategoryTile(icon: icon, color: color, size: .small)

                VStack(alignment: .leading, spacing: .zero) {
                    Text(title)
                        .dsLabel(font: DS.Font.labelSmall)

                    Text(amount)
                        .font(DS.Font.money)
                        .foregroundStyle(isIncome ? DS.Color.income : DS.Color.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(Metrics.minimumScale)
                }
            }
            .padding(.vertical, Metrics.flowVertical)
            .padding(.horizontal, DS.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.outlineClick(radius: DS.Radius.card))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(amount) \(AppString.currencySymbol)")
        .accessibilityHint(AppString.openStatisticsHint)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/Main.html` (баланс, .box доходов и расходов)
    static let balanceTop: CGFloat = 2
    static let flowSpacing: CGFloat = 10
    static let flowVertical: CGFloat = 10
    static let minimumScale: CGFloat = 0.5
}

// MARK: - Previews

#if DEBUG
private struct DashboardBalancePreview: View {

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Месяц") {
                DashboardBalanceView(title: AppString.onAccounts, balance: 975_050, income: 540_000, expenses: 131_950, onIncomeTap: {}, onExpenseTap: {})
            }
            DSPreviewCase("Все время") {
                DashboardBalanceView(title: AppString.balanceAllTime, balance: 975_050, income: 1_220_000, expenses: 244_950, onIncomeTap: {}, onExpenseTap: {})
            }
            DSPreviewCase("Пусто") {
                DashboardBalanceView(title: AppString.onAccounts, balance: 0, income: 0, expenses: 0, showsFlows: false, onIncomeTap: {}, onExpenseTap: {})
            }
            DSPreviewCase("Минус и длинные суммы") {
                DashboardBalanceView(title: AppString.onAccounts, balance: -12_345_678, income: 98_765_432, expenses: 123_456_789, onIncomeTap: {}, onExpenseTap: {})
            }
        }
    }
}

#Preview("Светлая") {
    DashboardBalancePreview()
}

#Preview("Темная") {
    DashboardBalancePreview()
        .preferredColorScheme(.dark)
}
#endif

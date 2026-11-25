//
//  DailyAllowanceCard.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Карточка «Можно потратить сегодня ›»: остаток на день, полоса потраченного и остаток месяца.
/// Обводка без тени. Без лимита — пунктирное приглашение его задать. Тап открывает «Лимит на месяц»
struct DailyAllowanceCard: View {

    // MARK: - Properties

    /// nil — лимит на месяц не задан
    let allowance: DailyAllowance?
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Group {
            if let allowance {
                AllowanceContent(summary: DailyAllowanceSummary(allowance: allowance), action: action)
            } else {
                LimitPrompt(action: action)
            }
        }
        .accessibilityIdentifier(AccessibilityID.dailyAllowanceCard)
        .accessibilityHint(AppString.monthlyLimitTitle)
    }
}

// MARK: - Allowance

private struct AllowanceContent: View {

    // MARK: - Properties

    let summary: DailyAllowanceSummary
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: .zero) {
                HStack {
                    Text(summary.title)
                        .dsLabel()
                        .lineLimit(1)

                    Spacer(minLength: DS.Spacing.sm)

                    DS.Icon.chevronRight
                        .font(.system(size: DS.Size.iconS, weight: .bold))
                }

                amountRow
                    .padding(.top, Metrics.amountTop)

                ProgressBar(progress: summary.spentFraction, size: .compact)
                    .padding(.top, DS.Spacing.md)
                    .animation(reduceMotion ? nil : DS.Motion.overlay, value: summary.spentFraction)

                HStack(alignment: .firstTextBaseline, spacing: DS.Spacing.sm) {
                    Text(summary.spentText)

                    Spacer(minLength: DS.Spacing.xs)

                    Text(summary.remainingText)
                        .multilineTextAlignment(.trailing)
                }
                .font(DS.Font.caption)
                .foregroundStyle(DS.Color.ink2)
                .lineLimit(1)
                .minimumScaleFactor(Metrics.minimumScale)
                .padding(.top, DS.Spacing.sm)
            }
            .padding(Card<EmptyView>.defaultPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.outlineClick(radius: DS.Radius.card))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    // MARK: - Subviews

    private var amountRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: Metrics.amountSpacing) {
            Text(MoneyFormat.money(summary.headlineAmount))
                .font(DS.Font.amountM)
                // Перерасход — красным: заголовок карточки уже назвал его
                .foregroundStyle(summary.isOver ? DS.Color.danger : DS.Color.ink)
                .lineLimit(1)
                .minimumScaleFactor(Metrics.minimumScale)
                .contentTransition(.numericText())

            if let allowanceOf = summary.allowanceOf {
                Text(AppString.ofAmount(MoneyFormat.number(allowanceOf)))
                    .font(DS.Font.moneySmall)
                    .foregroundStyle(DS.Color.ink2)
                    .lineLimit(1)
            }
        }
    }

    private var accessibilityText: String {
        [
            summary.title,
            MoneyFormat.money(summary.headlineAmount),
            summary.allowanceOf.map { AppString.ofAmount(MoneyFormat.money($0)) },
            summary.spentText,
            summary.remainingText
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
    }
}

// MARK: - Prompt

/// Пунктирная карточка «Сколько можно тратить в день?» — из `Design/html/MainEmpty.html`
private struct LimitPrompt: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Card(style: .dashed, padding: EdgeInsets(top: DS.Spacing.lg, leading: DS.Spacing.lg, bottom: DS.Spacing.lg, trailing: DS.Spacing.lg)) {
                HStack(spacing: DS.Spacing.md) {
                    AppImage.limitTarget
                        .font(.system(size: DS.Size.iconL, weight: .semibold))
                        .foregroundStyle(DS.Color.onAccent)
                        .frame(width: Metrics.promptIcon, height: Metrics.promptIcon)
                        .background(DS.Color.accent, in: RoundedRectangle(cornerRadius: Metrics.promptIconRadius))
                        .brutalBorder(radius: Metrics.promptIconRadius)

                    VStack(alignment: .leading, spacing: Metrics.promptTextSpacing) {
                        Text(AppString.monthlyLimitPromptTitle)
                            .font(DS.Font.bodyBold)

                        Text(AppString.monthlyLimitPromptHint)
                            .font(DS.Font.caption)
                            .foregroundStyle(DS.Color.ink2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                    DS.Icon.chevronRight
                        .font(.system(size: DS.Size.iconS, weight: .bold))
                }
            }
        }
        // Подсветка нажатия заливкой, обводку рисует сама пунктирная карточка
        .buttonStyle(OutlineClickStyle(shape: .segment, fill: .clear))
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/Main.html` (карточка лимита) и `MainEmpty.html` (.dashed)
    static let amountTop: CGFloat = 6
    static let amountSpacing: CGFloat = 10
    static let promptIcon: CGFloat = 40
    static let promptIconRadius: CGFloat = 9
    static let promptTextSpacing: CGFloat = 2
    static let minimumScale: CGFloat = 0.6
}

// MARK: - Previews

#if DEBUG
@MainActor
private enum DailyAllowancePreviewData {

    static let calendar = Calendar.current
    static let now = calendar.date(from: DateComponents(year: 2026, month: 11, day: 20, hour: 12)) ?? .now

    /// Лимит 250 000, до сегодня потрачено 125 000 → 11 363 на день
    static func allowance(spentToday: Decimal, spentBefore: Decimal = 125_000, limit: Decimal = 250_000) -> DailyAllowance {
        let environment = FixtureEnvironment(.empty)
        let context = environment.context
        let earlier = calendar.date(byAdding: .day, value: -3, to: now) ?? now
        var transactions: [Transaction] = []
        for (amount, date) in [(spentBefore, earlier), (spentToday, now)] where amount > 0 {
            let transaction = Transaction(amount: amount, date: date, type: .expense)
            context.insert(transaction)
            transactions.append(transaction)
        }
        return DailyAllowance(monthlyLimit: limit, transactions: transactions, now: now, calendar: calendar)
    }
}

private struct DailyAllowanceCardPreview: View {

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("В пределах дня") {
                DailyAllowanceCard(allowance: DailyAllowancePreviewData.allowance(spentToday: 6_950)) {}
            }
            DSPreviewCase("Перерасход за сегодня") {
                DailyAllowanceCard(allowance: DailyAllowancePreviewData.allowance(spentToday: 14_000)) {}
            }
            DSPreviewCase("Лимит на месяц превышен") {
                DailyAllowanceCard(allowance: DailyAllowancePreviewData.allowance(spentToday: 20_000, spentBefore: 260_000)) {}
            }
            DSPreviewCase("Лимит не задан") {
                DailyAllowanceCard(allowance: nil) {}
            }
        }
    }
}

#Preview("Светлая") {
    DailyAllowanceCardPreview()
}

#Preview("Темная") {
    DailyAllowanceCardPreview()
        .preferredColorScheme(.dark)
}
#endif

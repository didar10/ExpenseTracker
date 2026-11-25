//
//  BudgetsEmptyState.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Ни лимита, ни бюджетов: пунктирная карточка с мишенью и двумя действиями,
/// под ней — три шага «Как это работает»
struct BudgetsEmptyState: View {

    // MARK: - Types

    struct Step: Identifiable {
        let number: Int
        let title: String
        let subtitle: String

        var id: Int { number }
    }

    // MARK: - Properties

    let onSetLimit: () -> Void
    let onAddBudget: () -> Void

    private let steps = [
        Step(number: 1, title: AppString.budgetsStepLimitTitle, subtitle: AppString.budgetsStepLimitSubtitle),
        Step(number: 2, title: AppString.budgetsStepCategoriesTitle, subtitle: AppString.budgetsStepCategoriesSubtitle),
        Step(number: 3, title: AppString.budgetsStepHintsTitle, subtitle: AppString.budgetsStepHintsSubtitle)
    ]

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            promptCard

            Text(AppString.budgetsHowItWorks)
                .dsLabel()
                .padding(.horizontal, Metrics.sectionInset)
                .padding(.top, Metrics.sectionTop)
                .padding(.bottom, DS.Spacing.sm)
                .accessibilityAddTraits(.isHeader)

            stepsList
        }
    }
}

// MARK: - Subviews

private extension BudgetsEmptyState {

    var promptCard: some View {
        VStack(spacing: .zero) {
            AppImage.limitTarget
                .font(.system(size: Metrics.iconSize, weight: .semibold))
                .foregroundStyle(DS.Color.onAccent)
                .frame(width: Metrics.iconFrame, height: Metrics.iconFrame)
                .background(DS.Color.accent, in: RoundedRectangle(cornerRadius: DS.Radius.tabBar))
                .brutalBorder(radius: DS.Radius.tabBar)
                .accessibilityHidden(true)

            Text(AppString.budgetsEmptyTitle)
                .font(DS.Font.sheetTitle)
                .foregroundStyle(DS.Color.ink)
                .padding(.top, DS.Spacing.lg)
                .accessibilityAddTraits(.isHeader)

            Text(AppString.budgetsEmptyHint)
                .font(DS.Font.bodySmall)
                .foregroundStyle(DS.Color.ink2)
                .frame(maxWidth: Metrics.hintWidth)
                .padding(.top, Metrics.hintTop)

            PrimaryButton(title: AppString.budgetsSetMonthlyLimit, icon: DS.Icon.plus, action: onSetLimit)
                .padding(.top, Metrics.buttonTop)

            Button(action: onAddBudget) {
                Text(AppString.budgetsAddCategoryBudget)
                    .font(DS.Font.buttonSmall)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, minHeight: DS.Size.menuRow)
            }
            .buttonStyle(.outlineClick)
            .padding(.top, Metrics.buttonSpacing)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.vertical, Metrics.cardVerticalPadding)
        .padding(.horizontal, Metrics.cardHorizontalPadding)
        .background {
            HatchPattern(stripeWidth: HatchPattern.Metrics.wideStripeWidth)
                .opacity(Metrics.hatchOpacity)
        }
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card))
        .overlay {
            RoundedRectangle(cornerRadius: DS.Radius.card)
                .strokeBorder(DS.Color.ink, style: StrokeStyle(lineWidth: DS.Stroke.regular, dash: DS.Stroke.dash))
        }
    }

    var stepsList: some View {
        Card(padding: nil) {
            VStack(spacing: .zero) {
                ForEach(steps) { step in
                    if step.number > 1 {
                        ListDivider()
                    }

                    stepRow(step)
                }
            }
        }
    }

    func stepRow(_ step: Step) -> some View {
        HStack(spacing: DS.Spacing.md) {
            Text(step.number, format: .number)
                .font(DS.Font.money)
                .foregroundStyle(DS.Color.onAccent)
                .frame(width: Metrics.numberSide, height: Metrics.numberSide)
                .background(DS.Color.accent, in: RoundedRectangle(cornerRadius: Metrics.numberRadius))
                .brutalBorder(radius: Metrics.numberRadius)

            VStack(alignment: .leading, spacing: Metrics.stepTextSpacing) {
                Text(step.title)
                    .font(DS.Font.bodyBold)
                    .foregroundStyle(DS.Color.ink)

                Text(step.subtitle)
                    .font(DS.Font.caption)
                    .foregroundStyle(DS.Color.ink2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, DS.Spacing.sm)
        .padding(.leading, DS.Spacing.md)
        .padding(.trailing, Metrics.rowTrailing)
        .frame(minHeight: Metrics.rowHeight)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/BudgetsEmpty.html`
    static let cardVerticalPadding: CGFloat = 26
    static let cardHorizontalPadding: CGFloat = 18
    /// Штриховка фона вдвое бледнее штриховки остатка: rgba(17,17,17,.04) против .08
    static let hatchOpacity: Double = 0.5
    static let iconFrame: CGFloat = 64
    static let iconSize: CGFloat = 30
    static let hintTop: CGFloat = 6
    static let hintWidth: CGFloat = 270
    static let buttonTop: CGFloat = 18
    static let buttonSpacing: CGFloat = 10
    static let sectionTop: CGFloat = 22
    static let sectionInset: CGFloat = 2
    static let numberSide: CGFloat = 34
    static let numberRadius: CGFloat = 9
    static let stepTextSpacing: CGFloat = 2
    static let rowTrailing: CGFloat = 14
    static let rowHeight: CGFloat = 56
}

// MARK: - Previews

#if DEBUG
#Preview("Светлая") {
    ScrollView {
        BudgetsEmptyState(onSetLimit: {}, onAddBudget: {})
            .padding(.horizontal, DS.Spacing.xl)
    }
    .background(DS.Color.bg)
}

#Preview("Темная") {
    ScrollView {
        BudgetsEmptyState(onSetLimit: {}, onAddBudget: {})
            .padding(.horizontal, DS.Spacing.xl)
    }
    .background(DS.Color.bg)
    .preferredColorScheme(.dark)
}
#endif

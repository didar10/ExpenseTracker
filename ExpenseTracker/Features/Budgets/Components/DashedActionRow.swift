//
//  DashedActionRow.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Пунктирная строка-приглашение: «+ Бюджет на категорию · не распределено 65 000 ₸».
/// Прозрачная, без тени — это не главное действие экрана
struct DashedActionRow: View {

    // MARK: - Properties

    var icon: Image = DS.Icon.plus
    let title: String
    var subtitle: String?
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.md) {
                icon
                    .font(.system(size: DS.Size.iconM, weight: .bold))
                    .frame(width: Metrics.tileSide, height: Metrics.tileSide)
                    .background(DS.Color.bg, in: RoundedRectangle(cornerRadius: Metrics.tileRadius))
                    .overlay {
                        RoundedRectangle(cornerRadius: Metrics.tileRadius)
                            .strokeBorder(DS.Color.ink, style: dashedStroke)
                    }
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: .zero) {
                    Text(title)
                        .font(DS.Font.control)
                        .foregroundStyle(DS.Color.ink)

                    if let subtitle {
                        Text(subtitle)
                            .font(DS.Font.moneySmall)
                            .foregroundStyle(DS.Color.ink2)
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(Metrics.minimumScale)
                .frame(maxWidth: .infinity, alignment: .leading)

                DS.Icon.chevronRight
                    .font(.system(size: DS.Size.iconS, weight: .bold))
                    .foregroundStyle(DS.Color.ink)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, Metrics.horizontalPadding)
            .frame(minHeight: Metrics.height)
            .contentShape(RoundedRectangle(cornerRadius: DS.Radius.card))
            .overlay {
                RoundedRectangle(cornerRadius: DS.Radius.card)
                    .strokeBorder(DS.Color.ink, style: dashedStroke)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Private

    private var dashedStroke: StrokeStyle {
        StrokeStyle(lineWidth: DS.Stroke.regular, dash: DS.Stroke.dash)
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/Budgets.html` (.dashed)
    static let height: CGFloat = 54
    static let horizontalPadding: CGFloat = 14
    static let tileSide: CGFloat = 34
    static let tileRadius: CGFloat = 9
    static let minimumScale: CGFloat = 0.8
}

// MARK: - Previews

#if DEBUG
private struct DashedActionRowGallery: View {

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Не распределено") {
                DashedActionRow(title: AppString.budgetsAddCategoryBudget, subtitle: AppString.budgetsUnallocated(MoneyFormat.money(65_000))) {}
            }
            DSPreviewCase("Без лимита") {
                DashedActionRow(title: AppString.budgetsAddCategoryBudget) {}
            }
            DSPreviewCase("Лимит не задан") {
                DashedActionRow(icon: AppImage.limitTarget, title: AppString.budgetsLimitPromptTitle, subtitle: AppString.budgetsLimitPromptHint) {}
            }
        }
    }
}

#Preview("Светлая") {
    DashedActionRowGallery()
}

#Preview("Темная") {
    DashedActionRowGallery()
        .preferredColorScheme(.dark)
}
#endif

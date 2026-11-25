//
//  DashboardCompactHeader.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Шапка, которая закрепляется сверху при прокрутке: «Все счета · Ноябрь», баланс
/// и период без стрелок. Снизу — обводка, отделяющая ленту
struct DashboardCompactHeader<PeriodControl: View>: View {

    // MARK: - Properties

    let title: String
    let balance: Decimal
    @ViewBuilder let periodControl: PeriodControl

    // MARK: - Body

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            VStack(alignment: .leading, spacing: .zero) {
                Text(title)
                    .dsLabel(font: DS.Font.labelSmall)
                    .lineLimit(1)

                Text(MoneyFormat.money(balance))
                    .font(DS.Font.amountS)
                    .foregroundStyle(DS.Color.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(Metrics.minimumScale)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)

            periodControl
        }
        .padding(.horizontal, DS.Spacing.xl)
        .padding(.top, Metrics.topPadding)
        .padding(.bottom, Metrics.bottomPadding)
        .background(DS.Color.bg.ignoresSafeArea(edges: .top))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(DS.Color.ink)
                .frame(height: DS.Stroke.regular)
        }
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/MainScrolled.html`
    static let topPadding: CGFloat = 6
    static let bottomPadding: CGFloat = 10
    static let minimumScale: CGFloat = 0.6
}

// MARK: - Previews

#if DEBUG
private struct DashboardCompactHeaderPreview: View {

    var body: some View {
        VStack(spacing: DS.Spacing.xl) {
            DashboardCompactHeader(title: AppString.allAccounts + AppString.titleSeparator + "Ноябрь", balance: 975_050) {
                DashboardPeriodControl(filter: .preview(.month), allowsArrows: false, onSelect: { _ in }, onPrevious: {}, onNext: {})
            }

            DashboardCompactHeader(title: "Kaspi Gold" + AppString.titleSeparator + "Все время", balance: 0) {
                DashboardPeriodControl(filter: .preview(.allTime), allowsArrows: false, onSelect: { _ in }, onPrevious: {}, onNext: {})
            }

            Spacer()
        }
        .background(DS.Color.bg)
    }
}

#Preview("Светлая") {
    DashboardCompactHeaderPreview()
}

#Preview("Темная") {
    DashboardCompactHeaderPreview()
        .preferredColorScheme(.dark)
}
#endif

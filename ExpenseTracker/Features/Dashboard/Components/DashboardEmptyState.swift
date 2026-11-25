//
//  DashboardEmptyState.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Пустая лента: иконка в пунктирной рамке, «Операций пока нет» и подсказка.
/// Если пусто только в выбранном периоде — кнопка «Все время»
struct DashboardEmptyState: View {

    // MARK: - Properties

    let hint: String
    /// nil — операций нет совсем, сбрасывать период незачем
    var onShowAllTime: (() -> Void)?

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            AppImage.textAlign
                .font(.system(size: DS.Size.iconXL, weight: .semibold))
                .foregroundStyle(DS.Color.ink)
                .frame(width: Metrics.frame, height: Metrics.frame)
                .overlay {
                    RoundedRectangle(cornerRadius: Metrics.frameRadius)
                        .strokeBorder(DS.Color.ink, style: StrokeStyle(lineWidth: DS.Stroke.regular, dash: DS.Stroke.dash))
                }
                .accessibilityHidden(true)

            Text(AppString.noTransactionsYet)
                .font(DS.Font.dialogTitle)
                .foregroundStyle(DS.Color.ink)
                .padding(.top, DS.Spacing.lg)
                .accessibilityAddTraits(.isHeader)

            Text(hint)
                .font(DS.Font.bodySmall)
                .foregroundStyle(DS.Color.ink2)
                .frame(maxWidth: Metrics.hintWidth)
                .padding(.top, Metrics.hintTop)

            if let onShowAllTime {
                Button(action: onShowAllTime) {
                    Text(AppString.periodAllTime)
                        .font(DS.Font.control)
                        .padding(.horizontal, DS.Spacing.lg)
                        .frame(minHeight: DS.Size.control)
                }
                .buttonStyle(.outlineClick)
                .padding(.top, DS.Spacing.lg)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/MainEmpty.html`
    static let frame: CGFloat = 72
    static let frameRadius: CGFloat = 18
    static let hintTop: CGFloat = 6
    static let hintWidth: CGFloat = 260
}

// MARK: - Previews

#if DEBUG
private struct DashboardEmptyStatePreview: View {

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Операций нет") {
                DashboardEmptyState(hint: AppString.noTransactionsHint)
            }
            DSPreviewCase("Пусто в периоде") {
                DashboardEmptyState(hint: AppString.noTransactionsInPeriod("Октябрь")) {}
            }
        }
    }
}

#Preview("Светлая") {
    DashboardEmptyStatePreview()
}

#Preview("Темная") {
    DashboardEmptyStatePreview()
        .preferredColorScheme(.dark)
}
#endif

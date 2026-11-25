//
//  PeriodSelector.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Выбор периода: ‹ Ноябрь ▾ ›. Стрелки отделены от названия обводкой.
/// Тап по названию открывает выбор периода, стрелки листают на один период
struct PeriodSelector: View {

    // MARK: - Types

    enum Layout {
        /// По содержимому — рядом с пилюлей счета на главной
        case compact
        /// На всю ширину: стрелки по 44, название по центру — бюджеты
        case fullWidth
    }

    // MARK: - Properties

    let title: String
    var layout: Layout = .compact
    /// false на текущем периоде: в будущее листать нельзя
    var isNextEnabled = true
    var isPreviousEnabled = true
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onTitleTap: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: .zero) {
            arrow(DS.Icon.chevronLeft, label: AppString.dsPreviousPeriod, action: onPrevious)
                .disabled(!isPreviousEnabled)

            separator

            titleButton

            separator

            arrow(DS.Icon.chevronRight, label: AppString.dsNextPeriod, action: onNext)
                .disabled(!isNextEnabled)
        }
        .frame(height: DS.Size.control)
        .frame(maxWidth: layout == .fullWidth ? .infinity : nil)
        .background(DS.Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.control))
        .brutalBorder(radius: DS.Radius.control)
        .fixedSize(horizontal: layout == .compact, vertical: false)
    }
}

// MARK: - Subviews

private extension PeriodSelector {

    var titleButton: some View {
        Button(action: onTitleTap) {
            HStack(spacing: DS.Spacing.xs) {
                Text(title)
                    .font(DS.Font.control)
                    .lineLimit(1)

                DS.Icon.chevronDown
                    .font(.system(size: DS.Size.iconXS, weight: .bold))
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, Metrics.titlePadding)
            .frame(maxWidth: layout == .fullWidth ? .infinity : nil, maxHeight: .infinity)
        }
        .buttonStyle(.outlineClickSegment)
        .accessibilityHint(AppString.dsChoosePeriodHint)
    }

    func arrow(_ icon: Image, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            icon
                .font(.system(size: DS.Size.iconM, weight: .bold))
                .frame(width: arrowWidth)
                .frame(maxHeight: .infinity)
        }
        .buttonStyle(.outlineClickSegment)
        .accessibilityLabel(label)
    }

    var separator: some View {
        Rectangle()
            .fill(DS.Color.ink)
            .frame(width: DS.Stroke.regular)
    }

    var arrowWidth: CGFloat {
        switch layout {
        case .compact: return Metrics.compactArrowWidth
        case .fullWidth: return DS.Size.control
        }
    }
}

// MARK: - Metrics

private extension PeriodSelector {

    /// Размеры из `Design/html/Main.html` (.seg) и `Budgets.html` (.pbar)
    enum Metrics {
        /// Иконка 18 и отступы по 10
        static let compactArrowWidth: CGFloat = 38
        static let titlePadding: CGFloat = 6
    }
}

// MARK: - Previews

#if DEBUG
private struct PeriodSelectorGallery: View {

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Compact · текущий месяц, › disabled") {
                PeriodSelector(title: "Ноябрь", isNextEnabled: false, onPrevious: {}, onNext: {}, onTitleTap: {})
            }
            DSPreviewCase("Compact · прошлый месяц") {
                PeriodSelector(title: "Октябрь", onPrevious: {}, onNext: {}, onTitleTap: {})
            }
            DSPreviewCase("FullWidth · текущий") {
                PeriodSelector(title: "Ноябрь 2026", layout: .fullWidth, isNextEnabled: false, onPrevious: {}, onNext: {}, onTitleTap: {})
            }
            DSPreviewCase("FullWidth · прошлый") {
                PeriodSelector(title: "Октябрь 2026", layout: .fullWidth, onPrevious: {}, onNext: {}, onTitleTap: {})
            }
            DSPreviewCase("Нажатый сегмент") {
                OutlineClickBody(shape: .segment, fill: .clear, isPressed: true) {
                    Text("Ноябрь")
                        .font(DS.Font.control)
                        .padding(.horizontal, DS.Spacing.sm)
                        .frame(height: DS.Size.control)
                }
                .brutalBorder(radius: DS.Radius.control)
            }
        }
    }
}

#Preview("Светлая") {
    PeriodSelectorGallery()
}

#Preview("Темная") {
    PeriodSelectorGallery()
        .preferredColorScheme(.dark)
}
#endif

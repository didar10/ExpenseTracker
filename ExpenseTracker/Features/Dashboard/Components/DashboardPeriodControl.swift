//
//  DashboardPeriodControl.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Период главной: ‹ Ноябрь ▾ › и меню «Неделя / Месяц / Год / Всё время» по тапу на название.
/// «Все время» не листается — стрелок нет; в компактной шапке их нет всегда
struct DashboardPeriodControl: View {

    // MARK: - Properties

    let filter: PeriodFilter
    /// false — компактная шапка при прокрутке
    var allowsArrows = true
    let onSelect: (StatisticsPeriod) -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void

    @State private var isMenuShown = false

    // MARK: - Body

    var body: some View {
        PeriodSelector(
            title: filter.title,
            isNextEnabled: filter.canGoForward,
            isPreviousEnabled: filter.isNavigable,
            showsArrows: allowsArrows && filter.isNavigable,
            onPrevious: onPrevious,
            onNext: onNext
        ) {
            isMenuShown = true
        }
        .brutalMenu(
            isPresented: $isMenuShown,
            items: menuItems,
            alignment: .trailing,
            minWidth: BrutalMenuMetrics.periodMinWidth
        )
        .sensoryFeedback(.selection, trigger: filter)
    }
}

// MARK: - Subviews

private extension DashboardPeriodControl {

    var menuItems: [BrutalMenuItem] {
        PeriodFilter.availablePeriods.map { period in
            BrutalMenuItem(title: period.displayName, isSelected: period == filter.period) {
                onSelect(period)
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
private struct DashboardPeriodControlPreview: View {

    var body: some View {
        DSPreviewGallery {
            ForEach(PeriodFilter.availablePeriods) { period in
                DSPreviewCase(period.displayName) {
                    DashboardPeriodControl(filter: .preview(period), onSelect: { _ in }, onPrevious: {}, onNext: {})
                }
            }
            DSPreviewCase("Компактная шапка") {
                DashboardPeriodControl(filter: .preview(.month), allowsArrows: false, onSelect: { _ in }, onPrevious: {}, onNext: {})
            }
        }
    }
}

extension PeriodFilter {

    static func preview(_ period: StatisticsPeriod) -> PeriodFilter {
        var filter = PeriodFilter()
        filter.select(period)
        return filter
    }
}

#Preview("Светлая") {
    DashboardPeriodControlPreview()
}

#Preview("Темная") {
    DashboardPeriodControlPreview()
        .preferredColorScheme(.dark)
}
#endif

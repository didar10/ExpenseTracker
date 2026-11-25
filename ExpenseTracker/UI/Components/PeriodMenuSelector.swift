//
//  PeriodMenuSelector.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Период на главной и в статистике: ‹ Ноябрь ▾ › и меню периодов по тапу на название
/// (`MainPeriodMenu.html`). «Все время» не листается — стрелок нет
struct PeriodMenuSelector: View {

    // MARK: - Properties

    /// «Ноябрь», «2026», «Все время»
    let title: String
    let selection: StatisticsPeriod
    let periods: [StatisticsPeriod]
    /// Стрелки только у периодов, которые можно листать
    let isNavigable: Bool
    /// false на текущем периоде: в будущее листать нельзя
    let canGoForward: Bool
    /// false — компактная шапка главной при прокрутке
    var allowsArrows = true
    let onSelect: (StatisticsPeriod) -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void

    @State private var isMenuShown = false

    // MARK: - Body

    var body: some View {
        PeriodSelector(
            title: title,
            isNextEnabled: canGoForward,
            isPreviousEnabled: isNavigable,
            showsArrows: allowsArrows && isNavigable,
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
        .sensoryFeedback(.selection, trigger: title)
    }
}

// MARK: - Subviews

private extension PeriodMenuSelector {

    var menuItems: [BrutalMenuItem] {
        periods.map { period in
            BrutalMenuItem(
                title: period == .allTime ? AppString.periodAllTimeMenu : period.displayName,
                isSelected: period == selection
            ) {
                onSelect(period)
            }
        }
    }
}

// MARK: - Period Filter

extension PeriodMenuSelector {

    /// Период главной: хранится в `PeriodFilter`
    init(
        filter: PeriodFilter,
        allowsArrows: Bool = true,
        onSelect: @escaping (StatisticsPeriod) -> Void,
        onPrevious: @escaping () -> Void,
        onNext: @escaping () -> Void
    ) {
        self.init(
            title: filter.title,
            selection: filter.period,
            periods: PeriodFilter.availablePeriods,
            isNavigable: filter.isNavigable,
            canGoForward: filter.canGoForward,
            allowsArrows: allowsArrows,
            onSelect: onSelect,
            onPrevious: onPrevious,
            onNext: onNext
        )
    }
}

// MARK: - Previews

#if DEBUG
private struct PeriodMenuSelectorPreview: View {

    var body: some View {
        DSPreviewGallery {
            ForEach(PeriodFilter.availablePeriods) { period in
                DSPreviewCase(period.displayName) {
                    PeriodMenuSelector(filter: .preview(period), onSelect: { _ in }, onPrevious: {}, onNext: {})
                }
            }
            DSPreviewCase("Компактная шапка") {
                PeriodMenuSelector(filter: .preview(.month), allowsArrows: false, onSelect: { _ in }, onPrevious: {}, onNext: {})
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
    PeriodMenuSelectorPreview()
}

#Preview("Темная") {
    PeriodMenuSelectorPreview()
        .preferredColorScheme(.dark)
}
#endif

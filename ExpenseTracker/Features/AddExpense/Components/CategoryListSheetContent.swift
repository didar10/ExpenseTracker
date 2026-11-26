//
//  CategoryListSheetContent.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Как открыт лист категорий: из «Поиска» в ленте поле поиска сразу в фокусе
enum CategoryListSheetMode: Identifiable {
    case browse
    case search

    var id: Self { self }
}

/// Содержимое листа «Категории»: поиск и список с тратами за месяц.
/// Первая строка — «Без категории»; выбранная строка на accent. Выбор закрывает лист
struct CategoryListSheetContent: View {

    // MARK: - Properties

    let categories: [CarouselCategory]
    /// nil — «Без категории»
    let selection: UUID?
    var focusesSearch = false
    let onSelect: (UUID?) -> Void

    @State private var query = ""
    @FocusState private var isSearchFocused: Bool

    // MARK: - Computed Properties

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var filtered: [CarouselCategory] {
        guard !trimmedQuery.isEmpty else { return categories }
        return categories.filter { $0.title.localizedStandardContains(trimmedQuery) }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            searchField

            list
        }
        .padding(.bottom, DS.Spacing.sm)
        .onAppear {
            if focusesSearch { isSearchFocused = true }
        }
    }
}

// MARK: - Subviews

private extension CategoryListSheetContent {

    var searchField: some View {
        HStack(spacing: Metrics.searchSpacing) {
            DS.Icon.search
                .font(.system(size: DS.Size.iconM, weight: .semibold))
                .foregroundStyle(DS.Color.ink)
                .accessibilityHidden(true)

            TextField(
                AppString.findCategory,
                text: $query,
                prompt: Text(AppString.findCategory).foregroundStyle(DS.Color.ink2)
            )
            .font(DS.Font.body)
            .foregroundStyle(DS.Color.ink)
            .focused($isSearchFocused)
            .submitLabel(.search)
            .autocorrectionDisabled()
        }
        .padding(.horizontal, DS.Spacing.md)
        .frame(minHeight: Metrics.searchHeight)
        .background(DS.Color.surface, in: RoundedRectangle(cornerRadius: DS.Radius.control))
        .brutalBorder(radius: DS.Radius.control, lineWidth: isSearchFocused ? DS.Stroke.pressed : DS.Stroke.regular)
    }

    var list: some View {
        Card(padding: nil) {
            ScrollView {
                VStack(spacing: .zero) {
                    if trimmedQuery.isEmpty {
                        row(
                            id: nil,
                            title: AppString.noCategory,
                            amount: nil,
                            tile: tile(icon: DS.Icon.noCategory, color: DS.Color.noCategory)
                        )
                    }

                    ForEach(Array(filtered.enumerated()), id: \.element.id) { index, category in
                        if index > .zero || trimmedQuery.isEmpty {
                            ListDivider()
                        }
                        row(
                            id: category.id,
                            title: category.title,
                            amount: category.monthlySpend > .zero ? MoneyFormat.number(category.monthlySpend) : nil,
                            tile: tile(icon: category.icon, color: category.color, iconColor: category.iconColor)
                        )
                    }

                    if filtered.isEmpty {
                        Text(AppString.nothingFound)
                            .font(DS.Font.body)
                            .foregroundStyle(DS.Color.ink2)
                            .frame(maxWidth: .infinity)
                            .padding(Metrics.emptyPadding)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    func row(id: UUID?, title: String, amount: String?, tile: some View) -> some View {
        let isSelected = id == selection

        return Button {
            onSelect(id)
        } label: {
            HStack(spacing: DS.Spacing.md) {
                tile

                Text(title)
                    .font(DS.Font.bodyBold)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let amount {
                    Text(amount)
                        .font(DS.Font.moneySmall)
                        .foregroundStyle(isSelected ? DS.Color.onAccent : DS.Color.ink2)
                }
            }
            .padding(.leading, Metrics.rowLeading)
            .padding(.trailing, Metrics.rowTrailing)
            .frame(minHeight: Metrics.rowHeight)
            .background(isSelected ? DS.Color.accent : .clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(OutlineClickStyle(
            shape: .segment,
            fill: .clear,
            foreground: isSelected ? DS.Color.onAccent : DS.Color.ink
        ))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel([title, amount.map { "\($0) \(AppString.currencySymbol)" }].compactMap { $0 }.joined(separator: ", "))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    func tile(icon: Image, color: Color, iconColor: Color = DS.Color.ink) -> some View {
        icon
            .font(.system(size: DS.Size.iconS, weight: .semibold))
            .foregroundStyle(iconColor)
            .frame(width: Metrics.tile, height: Metrics.tile)
            .background(color, in: RoundedRectangle(cornerRadius: Metrics.tileRadius))
            .brutalBorder(radius: Metrics.tileRadius)
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/CategoryCarousel-06.html` (.srch, .r, .tl)
    static let searchHeight: CGFloat = 46
    static let searchSpacing: CGFloat = 10
    static let rowHeight: CGFloat = 54
    static let rowLeading: CGFloat = 10
    static let rowTrailing: CGFloat = 14
    static let tile: CGFloat = 34
    static let tileRadius: CGFloat = 9
    static let emptyPadding: CGFloat = 28
}

// MARK: - Previews

#if DEBUG
#Preview("Данные · светлая") {
    BrutalSheetLayout(title: AppString.categories) {
        CategoryListSheetContent(categories: CarouselPreviewData.categories, selection: nil) { _ in }
    }
}

#Preview("Выбрана категория · темная") {
    BrutalSheetLayout(title: AppString.categories) {
        CategoryListSheetContent(categories: CarouselPreviewData.categories, selection: CarouselPreviewData.categories.first?.id) { _ in }
    }
    .preferredColorScheme(.dark)
}

#Preview("Пусто") {
    BrutalSheetLayout(title: AppString.categories) {
        CategoryListSheetContent(categories: [], selection: nil) { _ in }
    }
}
#endif

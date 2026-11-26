//
//  CategoryCarousel.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Категория в ленте
struct CarouselCategory: Identifiable {

    // MARK: - Properties

    let id: UUID
    let title: String
    let icon: Image
    let color: Color
    /// Траты за текущий месяц — по ним сортируется лента
    let monthlySpend: Decimal
    /// Готовая подпись под названием: «18 400 ₸ в ноябре»; nil — без подписи
    var spendCaption: String?
    var iconColor: Color = DS.Color.ink

    // MARK: - Methods

    /// Порядок ленты: больше трат за месяц — ближе к «Без категории».
    /// Равные суммы сохраняют исходный порядок
    static func orderedBySpend(_ categories: [CarouselCategory]) -> [CarouselCategory] {
        categories.enumerated()
            .sorted { lhs, rhs in
                lhs.element.monthlySpend != rhs.element.monthlySpend
                    ? lhs.element.monthlySpend > rhs.element.monthlySpend
                    : lhs.offset < rhs.offset
            }
            .map(\.element)
    }
}

/// Лента выбора категории: плитка в центре увеличена и обведена рамкой-фокусом,
/// к краям плитки затухают. Слева от «Без категории» — «Поиск» и «Все категории»:
/// тап по ним, когда они в центре, открывает лист.
///
/// Лента занимает всю ширину экрана — родитель не должен давать ей боковые отступы
struct CategoryCarousel: View {

    // MARK: - Types

    enum Style {
        /// Экран новой операции: плитки 52, высота 118
        case regular
        /// Экран нового бюджета: плитки 36, высота 76
        case compact
    }

    /// Позиция в ленте
    enum Slot: Hashable {
        case allCategories
        case search
        case noCategory
        case category(UUID)
    }

    // MARK: - Properties

    /// Уже упорядоченные категории — см. `CarouselCategory.orderedBySpend`
    let categories: [CarouselCategory]
    /// nil — «Без категории». Пока в центре «Поиск» или «Все категории», выбор не меняется
    @Binding var selection: UUID?
    let style: Style
    /// Подпись рядом с «Без категории»: «выберите категорию свайпом»; nil — без подписи
    var noCategoryCaption: String?
    let onSearch: () -> Void
    let onAllCategories: () -> Void

    @State private var centered: Slot?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Init

    init(
        categories: [CarouselCategory],
        selection: Binding<UUID?>,
        style: Style = .regular,
        noCategoryCaption: String? = nil,
        onSearch: @escaping () -> Void,
        onAllCategories: @escaping () -> Void
    ) {
        self.categories = categories
        self._selection = selection
        self.style = style
        self.noCategoryCaption = noCategoryCaption
        self.onSearch = onSearch
        self.onAllCategories = onAllCategories
        // Начальная позиция задается до первой раскладки, иначе лента стартует со сдвигом
        self._centered = State(initialValue: selection.wrappedValue.map(Slot.category) ?? .noCategory)
    }

    // MARK: - Computed Properties

    private var metrics: CarouselMetrics {
        CarouselMetrics(style)
    }

    private var slots: [Slot] {
        [.allCategories, .search, .noCategory] + categories.map { .category($0.id) }
    }

    private var selectedSlot: Slot {
        selection.map(Slot.category) ?? .noCategory
    }

    private var scrollAnimation: Animation? {
        reduceMotion ? nil : DS.Motion.tabSwitch
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            track
            focusFrame
            fades
            label
        }
        .frame(height: metrics.height)
        .frame(maxWidth: .infinity)
        .background(DS.Color.surface)
        .overlay(alignment: .top) { horizontalBorder }
        .overlay(alignment: .bottom) { horizontalBorder }
        .onChange(of: centered) { _, slot in
            applyCentered(slot)
        }
        .onChange(of: selection) { _, _ in
            // Выбор поменяли снаружи (лист «Все категории») — подводим плитку к центру
            guard centered != selectedSlot else { return }
            withAnimation(scrollAnimation) { centered = selectedSlot }
        }
        .sensoryFeedback(.selection, trigger: centered)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AppString.category)
        .accessibilityValue(accessibilityValue)
        .accessibilityHint(isTool(centered) ? accessibilityValue : "")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: move(by: 1)
            case .decrement: move(by: -1)
            @unknown default: break
            }
        }
        .accessibilityAction { activate(centered ?? selectedSlot) }
    }
}

// MARK: - Subviews

private extension CategoryCarousel {

    var track: some View {
        let tile = metrics.tile
        let step = tile + metrics.spacing
        let maxScale = metrics.maxScale

        // Ширина нужна уже в первой раскладке: с нулевыми полями scrollPosition встает не туда
        return GeometryReader { geometry in
            ScrollViewReader { reader in
                ScrollView(.horizontal) {
                    // Не Lazy: категорий десятки, а у ленивого стека scrollPosition
                    // при старте считается по оценочным размерам и промахивается
                    HStack(spacing: metrics.spacing) {
                        ForEach(slots, id: \.self) { slot in
                            tileView(slot)
                                .visualEffect { content, proxy in
                                    let frame = proxy.frame(in: .scrollView)
                                    let viewport = proxy.bounds(of: .scrollView)?.width ?? frame.width
                                    // Расстояние до центра в шагах ленты: 0 — в центре, 1 — соседняя плитка
                                    let distance = abs(frame.midX - viewport / 2) / step
                                    let closeness = max(.zero, 1 - distance)

                                    return content
                                        .scaleEffect(1 + (maxScale - 1) * closeness, anchor: CarouselMetrics.scaleAnchor)
                                        .opacity(max(CarouselMetrics.minOpacity, 1 - CarouselMetrics.opacityStep * distance))
                                }
                                .id(slot)
                        }
                    }
                    .scrollTargetLayout()
                    .frame(height: metrics.frame)
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $centered, anchor: .center)
                .contentMargins(.horizontal, max(.zero, (geometry.size.width - tile) / 2), for: .scrollContent)
                // Увеличенная плитка выходит за высоту ряда — не обрезаем
                .scrollClipDisabled()
                .onAppear { reader.scrollTo(centered, anchor: .center) }
            }
        }
        .frame(height: metrics.frame)
        .padding(.top, metrics.frameTop)
    }

    func tileView(_ slot: Slot) -> some View {
        let shape = RoundedRectangle(cornerRadius: metrics.tileRadius)
        let iconColor: Color
        if case .category(let id) = slot {
            iconColor = categories.first(where: { $0.id == id })?.iconColor ?? DS.Color.ink
        } else {
            iconColor = DS.Color.ink
        }

        return Button {
            tap(slot)
        } label: {
            icon(for: slot)
                .font(.system(size: metrics.iconSize, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: metrics.tile, height: metrics.tile)
                .background(fill(for: slot), in: shape)
                .overlay {
                    if isTool(slot) {
                        shape.strokeBorder(DS.Color.ink, style: StrokeStyle(lineWidth: DS.Stroke.regular, dash: DS.Stroke.dash))
                    } else {
                        shape.strokeBorder(DS.Color.ink, lineWidth: DS.Stroke.regular)
                    }
                }
        }
        // Плитка окрашена цветом категории: щелчок только утолщает обводку до 2.5 pt
        .buttonStyle(OutlineClickStyle(shape: .segment(radius: metrics.tileRadius), fill: .clear, highlight: .borderOnly))
    }

    /// Рамка-фокус: обводка ink и внутреннее кольцо accent, стоит на месте
    var focusFrame: some View {
        let outer = RoundedRectangle(cornerRadius: metrics.frameRadius)
        let inner = RoundedRectangle(cornerRadius: metrics.frameRadius - CarouselMetrics.frameStroke)

        return outer
            .strokeBorder(DS.Color.ink, lineWidth: CarouselMetrics.frameStroke)
            .overlay {
                inner
                    .strokeBorder(DS.Color.accent, lineWidth: CarouselMetrics.frameRing)
                    .padding(CarouselMetrics.frameStroke)
            }
            .frame(width: metrics.frame, height: metrics.frame)
            .padding(.top, metrics.frameTop)
            .allowsHitTesting(false)
    }

    /// Затухание по краям поверх плиток
    var fades: some View {
        HStack(spacing: .zero) {
            LinearGradient(colors: [DS.Color.surface, DS.Color.surface.opacity(.zero)], startPoint: .leading, endPoint: .trailing)
                .frame(width: CarouselMetrics.fadeWidth)
            Spacer(minLength: .zero)
            LinearGradient(colors: [DS.Color.surface.opacity(.zero), DS.Color.surface], startPoint: .leading, endPoint: .trailing)
                .frame(width: CarouselMetrics.fadeWidth)
        }
        .frame(height: metrics.height - metrics.fadeBottom)
        .allowsHitTesting(false)
    }

    var label: some View {
        HStack(alignment: .firstTextBaseline, spacing: CarouselMetrics.captionSpacing) {
            switch centered ?? selectedSlot {
            case .search:
                Text(AppString.carouselSearchHint).foregroundStyle(DS.Color.ink2)
            case .allCategories:
                Text(AppString.carouselAllCategoriesHint).foregroundStyle(DS.Color.ink2)
            case .noCategory:
                Text(AppString.noCategory).foregroundStyle(DS.Color.ink)
                if let noCategoryCaption {
                    Text(noCategoryCaption)
                        .font(metrics.captionFont)
                        .foregroundStyle(DS.Color.ink2)
                }
            case .category(let id):
                if let category = categories.first(where: { $0.id == id }) {
                    Text(category.title).foregroundStyle(DS.Color.ink)
                    if let caption = category.spendCaption {
                        Text(caption)
                            .font(metrics.captionFont)
                            .foregroundStyle(DS.Color.ink2)
                    }
                }
            }
        }
        .font(metrics.labelFont)
        .lineLimit(1)
        .padding(.horizontal, DS.Spacing.lg)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, metrics.labelBottom)
        .allowsHitTesting(false)
    }

    var horizontalBorder: some View {
        Rectangle()
            .fill(DS.Color.ink)
            .frame(height: DS.Stroke.regular)
    }

    @ViewBuilder
    func icon(for slot: Slot) -> some View {
        switch slot {
        case .allCategories: DS.Icon.allCategories
        case .search: DS.Icon.search
        case .noCategory: DS.Icon.noCategory
        case .category(let id): categories.first { $0.id == id }?.icon
        }
    }

    func fill(for slot: Slot) -> Color {
        switch slot {
        case .allCategories, .search: return DS.Color.bg
        case .noCategory: return DS.Color.noCategory
        case .category(let id): return categories.first { $0.id == id }?.color ?? DS.Color.noCategory
        }
    }
}

// MARK: - Actions

private extension CategoryCarousel {

    /// Тап по плитке в центре открывает инструмент, по остальным — подводит плитку к центру
    func tap(_ slot: Slot) {
        guard slot != centered else {
            activate(slot)
            return
        }
        withAnimation(scrollAnimation) { centered = slot }
    }

    func activate(_ slot: Slot) {
        switch slot {
        case .search: onSearch()
        case .allCategories: onAllCategories()
        case .noCategory, .category: break
        }
    }

    func move(by offset: Int) {
        let current = slots.firstIndex(of: centered ?? selectedSlot) ?? .zero
        let next = min(max(current + offset, .zero), slots.count - 1)
        withAnimation(scrollAnimation) { centered = slots[next] }
    }

    func applyCentered(_ slot: Slot?) {
        switch slot {
        case .noCategory?: selection = nil
        case .category(let id)?: selection = id
        case .search?, .allCategories?, nil: break
        }
    }

    func isTool(_ slot: Slot?) -> Bool {
        slot == .search || slot == .allCategories
    }

    var accessibilityValue: String {
        switch centered ?? selectedSlot {
        case .search: return "\(AppString.searchCategory). \(AppString.carouselSearchHint)"
        case .allCategories: return "\(AppString.allCategories). \(AppString.carouselAllCategoriesHint)"
        case .noCategory: return AppString.noCategory
        case .category(let id):
            guard let category = categories.first(where: { $0.id == id }) else { return "" }
            return [category.title, category.spendCaption].compactMap { $0 }.joined(separator: ", ")
        }
    }
}

// MARK: - Metrics

/// Размеры из `Design/html/AddTransaction.html` (.car) и `AddBudgetFilled.html` (.carS)
private struct CarouselMetrics {

    let height: CGFloat
    let tile: CGFloat
    let tileRadius: CGFloat
    let iconSize: CGFloat
    let spacing: CGFloat
    let maxScale: CGFloat
    let frame: CGFloat
    let frameRadius: CGFloat
    /// Верх рамки-фокуса от верхнего края ленты
    let frameTop: CGFloat
    let labelBottom: CGFloat
    let fadeBottom: CGFloat
    let labelFont: Font
    let captionFont: Font

    static let scaleAnchor = UnitPoint(x: 0.5, y: 0.6)
    static let minOpacity: Double = 0.55
    static let opacityStep: Double = 0.12
    static let frameStroke: CGFloat = 2
    static let frameRing: CGFloat = 3
    static let fadeWidth: CGFloat = 46
    static let captionSpacing: CGFloat = 6

    init(_ style: CategoryCarousel.Style) {
        switch style {
        case .regular:
            height = 118
            tile = 52
            tileRadius = DS.Radius.card
            iconSize = DS.Size.iconXL
            spacing = 10
            maxScale = 1.28
            frame = 70
            frameRadius = 18
            frameTop = DS.Stroke.regular + 6
            labelBottom = DS.Stroke.regular + 8
            fadeBottom = 34
            labelFont = DS.Font.controlBold
            captionFont = DS.Font.moneySmall
        case .compact:
            height = 76
            tile = 36
            tileRadius = 10
            iconSize = DS.Size.iconS
            spacing = 10
            maxScale = 1.22
            frame = 50
            frameRadius = DS.Radius.card
            frameTop = DS.Stroke.regular + 6
            labelBottom = DS.Stroke.regular + 4
            fadeBottom = 22
            labelFont = DS.Font.control.weight(.bold)
            captionFont = DS.Font.moneyTiny
        }
    }
}

// MARK: - Previews

#if DEBUG
enum CarouselPreviewData {

    static let categories: [CarouselCategory] = CarouselCategory.orderedBySpend([
        .init(id: UUID(), title: "Продукты", icon: Image(systemName: "basket"), color: DS.CategoryColor.green.color, monthlySpend: 18_400, spendCaption: "18 400 ₸ в ноябре"),
        .init(id: UUID(), title: "Кафе и рестораны", icon: Image(systemName: "cup.and.saucer"), color: DS.CategoryColor.pink.color, monthlySpend: 9_600, spendCaption: "9 600 ₸ в ноябре"),
        .init(id: UUID(), title: "Покупки", icon: Image(systemName: "bag"), color: DS.CategoryColor.orange.color, monthlySpend: 28_500, spendCaption: "28 500 ₸ в ноябре"),
        .init(id: UUID(), title: "Транспорт", icon: Image(systemName: "car"), color: DS.CategoryColor.blue.color, monthlySpend: 7_200, spendCaption: "7 200 ₸ в ноябре"),
        .init(id: UUID(), title: "Спорт", icon: Image(systemName: "dumbbell"), color: DS.CategoryColor.purple.color, monthlySpend: 6_000, spendCaption: "6 000 ₸ в ноябре"),
        .init(id: UUID(), title: "Связь", icon: Image(systemName: "iphone"), color: DS.CategoryColor.blue.color, monthlySpend: 0, spendCaption: nil)
    ])
}

private struct CategoryCarouselPreview: View {

    @State var selection: UUID?
    var style: CategoryCarousel.Style = .regular

    var body: some View {
        VStack(spacing: DS.Spacing.xl) {
            CategoryCarousel(categories: CarouselPreviewData.categories, selection: $selection, style: style, onSearch: {}, onAllCategories: {})
            Text(selection.map { "selection: \($0.uuidString.prefix(4))" } ?? "selection: без категории")
                .font(DS.Font.moneySmall)
                .foregroundStyle(DS.Color.ink2)
        }
        .frame(maxHeight: .infinity)
        .background(DS.Color.bg)
    }
}

#Preview("Без категории · светлая") {
    CategoryCarouselPreview(selection: nil)
}

#Preview("Выбрана категория · темная") {
    CategoryCarouselPreview(selection: CarouselPreviewData.categories.first?.id)
        .preferredColorScheme(.dark)
}

#Preview("Compact · светлая") {
    CategoryCarouselPreview(selection: CarouselPreviewData.categories.first?.id, style: .compact)
}

#Preview("Compact · темная") {
    CategoryCarouselPreview(selection: nil, style: .compact)
        .preferredColorScheme(.dark)
}

#Preview("Пусто: нет категорий") {
    CategoryCarouselPreview(selection: nil)
}
#endif

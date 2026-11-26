//
//  FloatingTabBar.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Вкладка плавающего таббара
struct FloatingTab<Value: Hashable> {
    let value: Value
    let icon: Image
    /// Подпись для VoiceOver: у вкладок нет видимого текста
    let title: String
}

/// Плавающий таббар: панель с вкладками и отдельная кнопка «+» справа.
/// Панель — обводка без тени, активная вкладка — плашка ink с иконкой цвета bg;
/// «+» — accent с жесткой тенью.
///
/// Встраивается через `.floatingTabBar(...)` на `TabView`: модификатор скрывает системный
/// таббар не сам — каждой вкладке нужен `.toolbar(.hidden, for: .tabBar)`
struct FloatingTabBar<Value: Hashable>: View {

    // MARK: - Properties

    let tabs: [FloatingTab<Value>]
    @Binding var selection: Value
    let addAccessibilityLabel: String
    let onAdd: () -> Void

    @Namespace private var plaque
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Body

    var body: some View {
        HStack(spacing: Metrics.gap) {
            panel
            addButton
        }
        .padding(.horizontal, DS.Spacing.lg)
        .sensoryFeedback(.selection, trigger: selection)
    }
}

// MARK: - Subviews

private extension FloatingTabBar {

    var panel: some View {
        HStack(spacing: .zero) {
            ForEach(tabs, id: \.value) { tab in
                tabButton(tab)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, Metrics.panelPadding)
        .frame(height: DS.Size.tabBar)
        .background(DS.Color.surface, in: RoundedRectangle(cornerRadius: DS.Radius.tabBar))
        .brutalBorder(radius: DS.Radius.tabBar)
    }

    func tabButton(_ tab: FloatingTab<Value>) -> some View {
        let isSelected = tab.value == selection

        return Button {
            withAnimation(reduceMotion ? nil : DS.Motion.tabSwitch) {
                selection = tab.value
            }
        } label: {
            tab.icon
                .font(.system(size: DS.Size.iconTab, weight: .medium))
                .frame(width: DS.Size.tabItem, height: DS.Size.tabItem)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: DS.Radius.control)
                            .fill(DS.Color.ink)
                            .matchedGeometryEffect(id: Metrics.plaqueID, in: plaque)
                    }
                }
                .contentShape(Rectangle())
        }
        // Щелчок: плашка вкладки на 90 мс становится accent с обводкой 2.5 pt
        .buttonStyle(OutlineClickStyle(
            shape: .segment(radius: DS.Radius.control),
            fill: .clear,
            foreground: isSelected ? DS.Color.bg : DS.Color.ink2
        ))
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    var addButton: some View {
        Button(action: onAdd) {
            DS.Icon.plus
                .font(.system(size: DS.Size.iconAdd, weight: .semibold))
                .frame(width: DS.Size.tabBar, height: DS.Size.tabBar)
        }
        .buttonStyle(PressIntoShadowStyle(variant: .primary, radius: DS.Radius.tabBar))
        .frame(width: DS.Size.tabBar, height: DS.Size.tabBar)
        .accessibilityLabel(addAccessibilityLabel)
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/_TabBar.html` (.tbB)
    static let gap: CGFloat = 10
    static let panelPadding: CGFloat = 6
    /// Нижний край панели — 30 pt от края экрана
    static let bottomOffset: CGFloat = 30
    static let plaqueID = "plaque"
}

// MARK: - Embedding

extension View {

    /// Кладет таббар поверх контента у нижнего края экрана и сдвигает safe area контента так,
    /// чтобы последняя строка прокрутки не пряталась под панелью
    func floatingTabBar<Value: Hashable>(
        tabs: [FloatingTab<Value>],
        selection: Binding<Value>,
        isVisible: Bool = true,
        addAccessibilityLabel: String,
        onAdd: @escaping () -> Void
    ) -> some View {
        modifier(FloatingTabBarModifier(
            tabs: tabs,
            selection: selection,
            isVisible: isVisible,
            addAccessibilityLabel: addAccessibilityLabel,
            onAdd: onAdd
        ))
    }
}

private struct FloatingTabBarModifier<Value: Hashable>: ViewModifier {

    // MARK: - Properties

    let tabs: [FloatingTab<Value>]
    @Binding var selection: Value
    let isVisible: Bool
    let addAccessibilityLabel: String
    let onAdd: () -> Void

    // MARK: - Body

    func body(content: Content) -> some View {
        GeometryReader { proxy in
            let safeBottom = proxy.safeAreaInsets.bottom

            content
                .safeAreaInset(edge: .bottom, spacing: DS.Spacing.lg) {
                    if isVisible {
                        FloatingTabBar(
                            tabs: tabs,
                            selection: $selection,
                            addAccessibilityLabel: addAccessibilityLabel,
                            onAdd: onAdd
                        )
                        // Панель стоит в 30 pt от края экрана: на экранах без «челки» safe area
                        // нулевая — добавляем отступ, с индикатором «Домой» (34) — опускаем на разницу
                        .padding(.bottom, max(.zero, Metrics.bottomOffset - safeBottom))
                        .offset(y: max(.zero, safeBottom - Metrics.bottomOffset))
                    }
                }
        }
        // Клавиатура не поднимает таббар
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// MARK: - Previews

#if DEBUG
private enum PreviewTab: Hashable {
    case home, statistics, budgets, settings
}

private struct FloatingTabBarPreview: View {

    @State var selection: PreviewTab

    private let tabs: [FloatingTab<PreviewTab>] = [
        FloatingTab(value: .home, icon: Image(systemName: "house"), title: "Главная"),
        FloatingTab(value: .statistics, icon: Image(systemName: "chart.bar"), title: "Статистика"),
        FloatingTab(value: .budgets, icon: Image(systemName: "target"), title: "Бюджеты"),
        FloatingTab(value: .settings, icon: Image(systemName: "gearshape"), title: "Настройки")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.md) {
                ForEach(1...20, id: \.self) { index in
                    Card { Text("Строка \(index)").foregroundStyle(DS.Color.ink) }
                }
            }
            .padding(.horizontal, DS.Spacing.xl)
        }
        .background(DS.Color.bg)
        .floatingTabBar(tabs: tabs, selection: $selection, addAccessibilityLabel: "Добавить операцию") {}
    }
}

#Preview("Главная · светлая") {
    FloatingTabBarPreview(selection: .home)
}

#Preview("Бюджеты · темная") {
    FloatingTabBarPreview(selection: .budgets)
        .preferredColorScheme(.dark)
}
#endif

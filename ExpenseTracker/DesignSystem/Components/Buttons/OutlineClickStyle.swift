//
//  OutlineClickStyle.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// «Щелчок обводки» — нажатие для всего, что без тени: заливка становится accent, обводка — 2.5 pt.
/// Подсветка держится не меньше `DS.Motion.minimumHighlight` (90 мс), чтобы быстрый тап был заметен.
/// Сдвигов и масштаба нет, поэтому «Уменьшить движение» на стиль не влияет.
///
/// Основной цвет содержимого задает стиль (ink, на подсветке — onAccent): метке не нужно
/// красить главный текст и иконки, второстепенный текст красится явно
struct OutlineClickStyle: ButtonStyle {

    // MARK: - Types

    enum Shape {
        /// Самостоятельный контрол: своя заливка и обводка
        case bordered(radius: CGFloat)
        /// Часть составного контрола или строка списка (сегмент, стрелка периода, строка листа,
        /// вкладка): в покое обводки нет — ее рисует контейнер. При нажатии обводка 2.5 pt
        /// рисуется внутрь (`strokeBorder`), чтобы не вылезать за край строки
        case segment(radius: CGFloat = .zero)
        /// Круглая кнопка внутри более крупной зоны нажатия: «−» удаления в режиме правки
        case circle(diameter: CGFloat)
    }

    /// Что подсвечивается при нажатии
    enum Highlight {
        /// Заливка accent и обводка 2.5 pt
        case fillAndBorder
        /// Только обводка 2.5 pt: у образцов цвета (палитра, лента категорий) заливка и есть смысл кнопки
        case borderOnly
    }

    // MARK: - Properties

    var shape: Shape = .bordered(radius: DS.Radius.control)
    var fill: Color = DS.Color.surface
    /// Цвет содержимого в покое; на подсветке всегда onAccent
    var foreground: Color = DS.Color.ink
    /// Цвет обводки: ink, у опасного действия — danger
    var borderColor: Color = DS.Color.ink
    var highlight: Highlight = .fillAndBorder
    /// Насколько подсветка выходит за метку: строка списка, у которой отступы
    /// заданы снаружи кнопки, подсвечивается во всю ширину
    var bleed = EdgeInsets()

    // MARK: - Body

    func makeBody(configuration: Configuration) -> some View {
        OutlineClickBody(
            shape: shape,
            fill: fill,
            foreground: foreground,
            borderColor: borderColor,
            highlight: highlight,
            bleed: bleed,
            isPressed: configuration.isPressed
        ) {
            configuration.label
        }
    }
}

extension ButtonStyle where Self == OutlineClickStyle {

    static var outlineClick: OutlineClickStyle {
        OutlineClickStyle()
    }

    static func outlineClick(radius: CGFloat, fill: Color = DS.Color.surface) -> OutlineClickStyle {
        OutlineClickStyle(shape: .bordered(radius: radius), fill: fill)
    }

    /// Опасное действие без тени: «Убрать лимит» — красные текст и обводка
    static var outlineClickDanger: OutlineClickStyle {
        OutlineClickStyle(foreground: DS.Color.danger, borderColor: DS.Color.danger)
    }

    static var outlineClickSegment: OutlineClickStyle {
        OutlineClickStyle(shape: .segment(), fill: .clear)
    }

    /// Круглый «−» удаления в режиме правки: красные значок и обводка на своей заливке
    static func outlineClickDelete(diameter: CGFloat, fill: Color) -> OutlineClickStyle {
        OutlineClickStyle(
            shape: .circle(diameter: diameter),
            fill: fill,
            foreground: DS.Color.dangerFill,
            borderColor: DS.Color.dangerFill
        )
    }

    /// Строка списка, чьи отступы стоят снаружи кнопки: подсветка вылезает на них
    static func outlineClickRow(bleed: EdgeInsets) -> OutlineClickStyle {
        OutlineClickStyle(shape: .segment(), fill: .clear, bleed: bleed)
    }
}

// MARK: - Body

/// Внешний вид отдельно от `ButtonStyle`: превью показывают нажатое состояние через `isPressed`
struct OutlineClickBody<Label: View>: View {

    // MARK: - Properties

    let shape: OutlineClickStyle.Shape
    let fill: Color
    var foreground: Color = DS.Color.ink
    var borderColor: Color = DS.Color.ink
    var highlight: OutlineClickStyle.Highlight = .fillAndBorder
    var bleed = EdgeInsets()
    let isPressed: Bool
    @ViewBuilder let label: Label

    @Environment(\.isEnabled) private var isEnabled

    /// Подсветка отстает от `isPressed` при отпускании, но не раньше минимального времени
    @State private var isHighlighted = false
    @State private var highlightStart: ContinuousClock.Instant?
    @State private var releaseTask: Task<Void, Never>?

    // MARK: - Computed Properties

    private var isActive: Bool {
        (isPressed || isHighlighted) && isEnabled
    }

    private var isFilled: Bool {
        isActive && highlight == .fillAndBorder
    }

    // MARK: - Body

    var body: some View {
        label
            .foregroundStyle(isFilled ? DS.Color.onAccent : foreground)
            .background {
                surface
                    .padding(bleedPadding)
            }
            .overlay {
                border
                    .padding(bleedPadding)
            }
            .contentShape(Rectangle())
            .opacity(isEnabled ? 1 : Constants.disabledOpacity)
            .onAppear { isHighlighted = isPressed }
            .onChange(of: isPressed) { _, isPressedNow in
                isPressedNow ? beginHighlight() : endHighlight()
            }
            .onDisappear { releaseTask?.cancel() }
    }
}

// MARK: - Subviews

private extension OutlineClickBody {

    var surfaceColor: Color {
        isFilled ? DS.Color.accent : fill
    }

    var borderWidth: CGFloat {
        isActive ? DS.Stroke.pressed : DS.Stroke.regular
    }

    /// Круг рисуется по центру метки, а не во всю зону нажатия
    @ViewBuilder
    var surface: some View {
        switch shape {
        case .bordered(let radius), .segment(let radius):
            RoundedRectangle(cornerRadius: radius).fill(surfaceColor)
        case .circle(let diameter):
            Circle().fill(surfaceColor).frame(width: diameter, height: diameter)
        }
    }

    /// Отрицательный отступ выносит подсветку за метку
    var bleedPadding: EdgeInsets {
        EdgeInsets(top: -bleed.top, leading: -bleed.leading, bottom: -bleed.bottom, trailing: -bleed.trailing)
    }

    @ViewBuilder
    var border: some View {
        switch shape {
        case .bordered(let radius):
            RoundedRectangle(cornerRadius: radius).strokeBorder(borderColor, lineWidth: borderWidth)
        case .circle(let diameter):
            Circle().strokeBorder(borderColor, lineWidth: borderWidth).frame(width: diameter, height: diameter)
        case .segment(let radius):
            if isActive {
                RoundedRectangle(cornerRadius: radius).strokeBorder(DS.Color.ink, lineWidth: DS.Stroke.pressed)
            }
        }
    }
}

// MARK: - Private Methods

private extension OutlineClickBody {

    func beginHighlight() {
        releaseTask?.cancel()
        highlightStart = .now
        isHighlighted = true
    }

    func endHighlight() {
        let elapsed = highlightStart.map { ContinuousClock.now - $0 } ?? DS.Motion.minimumHighlight
        let remaining = DS.Motion.minimumHighlight - elapsed

        guard remaining > .zero else {
            isHighlighted = false
            return
        }

        releaseTask = Task { @MainActor in
            try? await Task.sleep(for: remaining)
            guard !Task.isCancelled else { return }
            isHighlighted = false
        }
    }
}

// MARK: - Constants

private enum Constants {
    /// Неактивная стрелка периода в макете — opacity .3
    static let disabledOpacity: Double = 0.3
}

//
//  OutlineClickStyle.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Нажатие для всего, что без тени: обводка утолщается до 2.5 pt, заливка становится accent.
/// Подсветка держится не меньше `DS.Motion.minimumHighlight`, чтобы быстрый тап был заметен.
///
/// Основной цвет содержимого задает стиль (ink, на подсветке — onAccent): метке не нужно
/// красить главный текст и иконки, второстепенный текст красится явно
struct OutlineClickStyle: ButtonStyle {

    // MARK: - Types

    enum Shape {
        /// Самостоятельный контрол: своя заливка и обводка
        case bordered(radius: CGFloat)
        /// Часть составного контрола (сегмент, стрелка периода): обводку рисует контейнер,
        /// при нажатии меняется только заливка
        case segment
    }

    // MARK: - Properties

    var shape: Shape = .bordered(radius: DS.Radius.control)
    var fill: Color = DS.Color.surface
    /// Цвет содержимого в покое; на подсветке всегда onAccent
    var foreground: Color = DS.Color.ink
    /// Цвет обводки: ink, у опасного действия — danger
    var borderColor: Color = DS.Color.ink

    // MARK: - Body

    func makeBody(configuration: Configuration) -> some View {
        OutlineClickBody(shape: shape, fill: fill, foreground: foreground, borderColor: borderColor, isPressed: configuration.isPressed) {
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
        OutlineClickStyle(shape: .segment, fill: .clear)
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

    // MARK: - Body

    var body: some View {
        label
            .foregroundStyle(isActive ? DS.Color.onAccent : foreground)
            .background(isActive ? DS.Color.accent : fill, in: backgroundShape)
            .overlay { border }
            .contentShape(backgroundShape)
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

    var backgroundShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: radius)
    }

    var radius: CGFloat {
        switch shape {
        case .bordered(let radius): return radius
        case .segment: return .zero
        }
    }

    @ViewBuilder
    var border: some View {
        if case .bordered = shape {
            backgroundShape.strokeBorder(
                borderColor,
                lineWidth: isActive ? DS.Stroke.pressed : DS.Stroke.regular
            )
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

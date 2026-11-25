//
//  PressIntoShadowStyle.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Кнопка с жесткой тенью: при нажатии лицевая сторона «вдавливается» в тень —
/// сдвигается на размер тени и закрывает ее. Только для главных действий.
///
/// Неактивное состояние берется из `.disabled(_:)`: фон bg, пунктирная обводка, без тени
struct PressIntoShadowStyle: ButtonStyle {

    // MARK: - Types

    enum Variant {
        /// Желтая кнопка сохранения
        case primary
        /// Кнопка удаления: красные текст, обводка и тень
        case danger
    }

    // MARK: - Properties

    let variant: Variant
    var radius: CGFloat = DS.Radius.control

    // MARK: - Body

    func makeBody(configuration: Configuration) -> some View {
        PressIntoShadowBody(variant: variant, radius: radius, isPressed: configuration.isPressed) {
            configuration.label
        }
    }
}

extension ButtonStyle where Self == PressIntoShadowStyle {

    static func pressIntoShadow(_ variant: PressIntoShadowStyle.Variant = .primary) -> PressIntoShadowStyle {
        PressIntoShadowStyle(variant: variant)
    }
}

// MARK: - Body

/// Внешний вид кнопки отдельно от `ButtonStyle`, чтобы превью могли показать нажатое состояние
struct PressIntoShadowBody<Label: View>: View {

    // MARK: - Properties

    let variant: PressIntoShadowStyle.Variant
    let radius: CGFloat
    let isPressed: Bool
    @ViewBuilder let label: Label

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Computed Properties

    private var shadow: DS.Shadow { .hard }

    private var fill: Color {
        guard isEnabled else { return DS.Color.bg }

        switch variant {
        case .primary: return DS.Color.accent
        case .danger: return DS.Color.surface
        }
    }

    private var foreground: Color {
        guard isEnabled else { return DS.Color.ink2 }

        switch variant {
        case .primary: return DS.Color.onAccent
        case .danger: return DS.Color.danger
        }
    }

    private var tint: Color {
        switch variant {
        case .primary: return DS.Color.ink
        case .danger: return DS.Color.danger
        }
    }

    /// Лицевая сторона сдвигается ровно на размер тени и закрывает ее
    private var faceOffset: CGSize {
        isPressed && isEnabled ? CGSize(width: shadow.x, height: shadow.y) : .zero
    }

    // MARK: - Body

    var body: some View {
        label
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .background(fill, in: RoundedRectangle(cornerRadius: radius))
            .overlay { border }
            .offset(faceOffset)
            .background { shadowShape }
            .animation(reduceMotion ? nil : DS.Motion.press, value: isPressed)
            .sensoryFeedback(.impact(weight: .light), trigger: isPressed) { _, isPressedNow in
                isPressedNow && isEnabled
            }
    }
}

// MARK: - Subviews

private extension PressIntoShadowBody {

    @ViewBuilder
    var border: some View {
        let shape = RoundedRectangle(cornerRadius: radius)

        if isEnabled {
            shape.strokeBorder(tint, lineWidth: DS.Stroke.regular)
        } else {
            shape.strokeBorder(DS.Color.ink2, style: StrokeStyle(lineWidth: DS.Stroke.regular, dash: DS.Stroke.dash))
        }
    }

    /// Тень стоит на месте, двигается только лицевая сторона
    @ViewBuilder
    var shadowShape: some View {
        if isEnabled {
            RoundedRectangle(cornerRadius: radius)
                .fill(tint)
                .offset(x: shadow.x, y: shadow.y)
        }
    }
}

//
//  DS+Modifiers.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

extension View {

    /// Обводка ink по контуру скругленного прямоугольника, внутри границ View — как `border` в CSS
    func brutalBorder(
        radius: CGFloat,
        lineWidth: CGFloat = DS.Stroke.regular,
        color: Color = DS.Color.ink
    ) -> some View {
        overlay {
            RoundedRectangle(cornerRadius: radius)
                .strokeBorder(color, lineWidth: lineWidth)
        }
    }

    /// Сплошная тень со сдвигом без размытия. Только у главных действий;
    /// у кнопки удаления — `color: DS.Color.danger`.
    /// View должна иметь непрозрачную заливку: тень повторяет ее силуэт
    func hardShadow(_ shadow: DS.Shadow = .hard, color: Color = DS.Color.ink) -> some View {
        compositingGroup()
            .shadow(color: color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }

    /// Метка раздела: SF Semibold 12, верхний регистр, разрядка 0.06em, цвет ink2.
    /// `font: DS.Font.labelSmall` — мелкая метка 11 pt
    func dsLabel(color: Color = DS.Color.ink2, font: Font = DS.Font.label) -> some View {
        modifier(DSLabelModifier(color: color, font: font))
    }
}

// MARK: - Label

private struct DSLabelModifier: ViewModifier {

    // MARK: - Properties

    let color: Color
    let font: Font

    /// Разрядка растет вместе со шрифтом при Dynamic Type
    @ScaledMetric(relativeTo: .caption) private var tracking = DS.Font.labelTracking

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .font(font)
            .textCase(.uppercase)
            .tracking(tracking)
            .foregroundStyle(color)
    }
}

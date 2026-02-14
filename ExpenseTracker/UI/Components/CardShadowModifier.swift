//
//  CardShadowModifier.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI

struct CardModifier: ViewModifier {
    var cornerRadius: CGFloat
    var fillColor: Color = Color(uiColor: .systemBackground)
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fillColor)
            )
    }
}

/// Модификатор для применения единого стиля теней к карточкам
struct CardShadowModifier: ViewModifier {
    var cornerRadius: CGFloat
    var fillColor: Color = Color(uiColor: .systemBackground)
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fillColor)
                    .shadow(
                        color: Color.primary.opacity(0.7),
                        radius: 0,
                        x: 1,
                        y: 2.5
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.7), lineWidth: 1.5)
            )
    }
}

/// Модификатор для применения единого стиля теней к круглым элементам
struct CircleShadowModifier: ViewModifier {
    var fillColor: Color = Color(uiColor: .systemBackground)
    
    func body(content: Content) -> some View {
        content
            .background(
                Circle()
                    .fill(fillColor)
                    .shadow(
                        color: Color.primary.opacity(0.7),
                        radius: 0,
                        x: 1,
                        y: 2
                    )
            )
            .overlay(
                Circle()
                    .strokeBorder(Color.primary.opacity(0.7), lineWidth: 1.5)
            )
    }
}

extension View {
    func card(cornerRadius: CGFloat = 16, fillColor: Color = Color(uiColor: .systemBackground)) -> some View {
        modifier(CardModifier(cornerRadius: cornerRadius, fillColor: fillColor))
    }
    
    /// Применяет стандартную тень карточки
    /// - Parameters:
    ///   - cornerRadius: Радиус скругления углов
    ///   - fillColor: Цвет фона карточки (по умолчанию systemBackground)
    func cardShadow(cornerRadius: CGFloat = 16, fillColor: Color = Color(uiColor: .systemBackground)) -> some View {
        modifier(CardShadowModifier(cornerRadius: cornerRadius, fillColor: fillColor))
    }
    
    /// Применяет стандартную тень для круглых элементов
    /// - Parameter fillColor: Цвет фона элемента (по умолчанию systemBackground)
    func circleShadow(fillColor: Color = Color(uiColor: .systemBackground)) -> some View {
        modifier(CircleShadowModifier(fillColor: fillColor))
    }
}

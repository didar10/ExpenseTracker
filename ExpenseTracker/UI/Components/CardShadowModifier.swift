//
//  CardShadowModifier.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI

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
                        color: .black.opacity(0.45),
                        radius: 0,
                        x: 2,
                        y: 4
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.12), lineWidth: 1.5)
            )
    }
}

extension View {
    /// Применяет стандартную тень карточки
    /// - Parameters:
    ///   - cornerRadius: Радиус скругления углов
    ///   - fillColor: Цвет фона карточки (по умолчанию systemBackground)
    func cardShadow(cornerRadius: CGFloat = 16, fillColor: Color = Color(uiColor: .systemBackground)) -> some View {
        modifier(CardShadowModifier(cornerRadius: cornerRadius, fillColor: fillColor))
    }
}

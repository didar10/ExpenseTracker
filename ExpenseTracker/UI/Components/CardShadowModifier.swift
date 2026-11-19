//
//  CardShadowModifier.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI

struct CardModifier: ViewModifier {
    var cornerRadius: CGFloat
    var fillColor: Color = Color.appCardBackground
    
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
    var fillColor: Color = Color.appCardBackground
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fillColor)
                    .shadow(
                        color: AppColor.cardShadow,
                        radius: 0,
                        x: 1,
                        y: 1.8
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(AppColor.cardBorder, lineWidth: 1.5)
            )
    }
}

/// Карточка «стопкой»: за ней лежит вторая такая же, сдвинутая вниз и чуть вправо.
/// Снизу видно обводку, тонкий светлый зазор и обводку нижней карточки
struct LayeredCardModifier: ViewModifier {

    // MARK: - Properties

    var cornerRadius: CGFloat
    var fillColor: Color = Color.appCardBackground

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .background(cardLayer)
            .background(
                cardLayer
                    .offset(x: Constants.backOffsetX, y: Constants.backOffsetY)
            )
    }

    // MARK: - Subviews

    private var cardLayer: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(fillColor)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(AppColor.cardBorder, lineWidth: Constants.borderWidth)
            )
    }
}

// MARK: - Constants

private extension LayeredCardModifier {

    enum Constants {
        static let borderWidth: CGFloat = 1.5
        /// Нижняя карточка выглядывает снизу сильнее, чем справа
        static let backOffsetX: CGFloat = 1
        /// Между обводками остается тонкий светлый зазор
        static let backOffsetY: CGFloat = 2.5
    }
}

/// Карточка с темным краем: за ней лежит вторая, сдвинутая вниз и чуть вправо, с толстой темной обводкой.
/// Снизу и справа видно обводку карточки, тонкий светлый зазор и плотный темный край
struct LedgeCardModifier: ViewModifier {

    // MARK: - Properties

    var cornerRadius: CGFloat
    var fillColor: Color = Color.appCardBackground

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .background(cardLayer(border: AppColor.cardBorder, width: Constants.borderWidth))
            .background(
                cardLayer(border: AppColor.cardLedge, width: Constants.ledgeWidth)
                    .offset(x: Constants.backOffsetX, y: Constants.backOffsetY)
            )
    }

    // MARK: - Subviews

    private func cardLayer(border: Color, width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(fillColor)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(border, lineWidth: width)
            )
    }
}

// MARK: - Constants

private extension LedgeCardModifier {

    enum Constants {
        static let borderWidth: CGFloat = 1.5
        /// Толщина темного края нижней карточки
        static let ledgeWidth: CGFloat = 2.5
        /// Нижняя карточка выглядывает снизу сильнее, чем справа.
        /// Сдвиг больше толщины края — между обводкой и краем остается светлый зазор
        static let backOffsetX: CGFloat = 1.5
        static let backOffsetY: CGFloat = 3.25
    }
}

/// Карточка «от руки»: две одинаковые обводки, вторая сдвинута вправо и вниз.
/// Обе рисуются поверх заливки, поэтому верхняя и левая линии второй видны внутри карточки
struct SketchCardModifier: ViewModifier {

    // MARK: - Properties

    var cornerRadius: CGFloat
    var fillColor: Color = Color.appCardBackground

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .background(shape.fill(fillColor))
            .overlay(outline)
            .overlay(
                outline
                    .offset(x: Constants.offsetX, y: Constants.offsetY)
                    .allowsHitTesting(false)
            )
    }

    // MARK: - Subviews

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    private var outline: some View {
        shape.strokeBorder(AppColor.cardBorder, lineWidth: Constants.borderWidth)
    }
}

// MARK: - Constants

private extension SketchCardModifier {

    enum Constants {
        static let borderWidth: CGFloat = 1.5
        static let offsetX: CGFloat = 2.5
        static let offsetY: CGFloat = 3.5
    }
}

/// Кнопка-плитка «стопкой»: черная обводка, за ней такая же плитка, заметно сдвинутая
/// вправо и вниз, и мягкая тень вокруг. Как layeredCard, но контрастнее и крупнее — для кнопок
struct StackedTileModifier: ViewModifier {

    // MARK: - Properties

    var cornerRadius: CGFloat
    var fillColor: Color = Color.appCardBackground

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .background(tile)
            .background(
                tile
                    .offset(x: Constants.backOffsetX, y: Constants.backOffsetY)
            )
            .background(
                shape
                    .fill(fillColor)
                    .shadow(color: AppColor.softShadow, radius: Constants.softShadowRadius)
                    .opacity(Constants.softShadowOpacity)
            )
    }

    // MARK: - Subviews

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    private var tile: some View {
        shape
            .fill(fillColor)
            .overlay(
                shape.strokeBorder(AppColor.textPrimary, lineWidth: Constants.borderWidth)
            )
    }
}

// MARK: - Constants

private extension StackedTileModifier {

    enum Constants {
        static let borderWidth: CGFloat = 2
        static let backOffsetX: CGFloat = 3
        static let backOffsetY: CGFloat = 4.5
        static let softShadowRadius: CGFloat = 14
        static let softShadowOpacity: Double = 0.6
    }
}

/// Модификатор для применения единого стиля теней к круглым элементам
struct CircleShadowModifier: ViewModifier {
    var fillColor: Color = Color.appCardBackground
    
    func body(content: Content) -> some View {
        content
            .background(
                Circle()
                    .fill(fillColor)
                    .shadow(
                        color: AppColor.cardShadow,
                        radius: 0,
                        x: 1,
                        y: 2
                    )
            )
            .overlay(
                Circle()
                    .strokeBorder(AppColor.cardBorder, lineWidth: 1.5)
            )
    }
}

extension View {
    func card(cornerRadius: CGFloat = 16, fillColor: Color = Color.appCardBackground) -> some View {
        modifier(CardModifier(cornerRadius: cornerRadius, fillColor: fillColor))
    }
    
    /// Применяет стандартную тень карточки
    /// - Parameters:
    ///   - cornerRadius: Радиус скругления углов
    ///   - fillColor: Цвет фона карточки (по умолчанию systemBackground)
    func cardShadow(cornerRadius: CGFloat = 16, fillColor: Color = Color.appCardBackground) -> some View {
        modifier(CardShadowModifier(cornerRadius: cornerRadius, fillColor: fillColor))
    }
    
    /// Карточка «стопкой» с обводкой и второй карточкой снизу
    func layeredCard(cornerRadius: CGFloat = AppRadius.card, fillColor: Color = Color.appCardBackground) -> some View {
        modifier(LayeredCardModifier(cornerRadius: cornerRadius, fillColor: fillColor))
    }

    /// Кнопка-плитка «стопкой» с черной обводкой, сдвинутой второй плиткой и мягкой тенью
    func stackedTile(cornerRadius: CGFloat = AppRadius.xLarge, fillColor: Color = Color.appCardBackground) -> some View {
        modifier(StackedTileModifier(cornerRadius: cornerRadius, fillColor: fillColor))
    }

    /// Карточка «от руки» с двумя сдвинутыми обводками
    func sketchCard(cornerRadius: CGFloat = AppRadius.card, fillColor: Color = Color.appCardBackground) -> some View {
        modifier(SketchCardModifier(cornerRadius: cornerRadius, fillColor: fillColor))
    }

    /// Карточка с обводкой, тонким светлым зазором и плотным темным краем снизу и справа
    func ledgeCard(cornerRadius: CGFloat = AppRadius.card, fillColor: Color = Color.appCardBackground) -> some View {
        modifier(LedgeCardModifier(cornerRadius: cornerRadius, fillColor: fillColor))
    }

    /// Применяет стандартную тень для круглых элементов
    /// - Parameter fillColor: Цвет фона элемента (по умолчанию systemBackground)
    func circleShadow(fillColor: Color = Color.appCardBackground) -> some View {
        modifier(CircleShadowModifier(fillColor: fillColor))
    }
}

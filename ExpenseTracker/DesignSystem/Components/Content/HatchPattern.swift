//
//  HatchPattern.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Диагональная штриховка −45° на прозрачном фоне: «пусто» или «остаток».
/// Ширина полосы и промежутка одинаковая, как `repeating-linear-gradient` в макетах
struct HatchPattern: View {

    // MARK: - Properties

    var color: Color = DS.Color.emptyHatch
    var stripeWidth: CGFloat = Metrics.defaultStripeWidth

    // MARK: - Body

    var body: some View {
        Canvas { context, size in
            let base = stripeWidth * Metrics.diagonalFactor
            var x = -size.height

            while x < size.width + size.height {
                var stripe = Path()
                stripe.move(to: CGPoint(x: x, y: size.height))
                stripe.addLine(to: CGPoint(x: x + size.height, y: .zero))
                stripe.addLine(to: CGPoint(x: x + size.height + base, y: .zero))
                stripe.addLine(to: CGPoint(x: x + base, y: size.height))
                stripe.closeSubpath()
                context.fill(stripe, with: .color(color))
                x += base * 2
            }
        }
        .accessibilityHidden(true)
    }
}

extension HatchPattern {

    enum Metrics {
        /// Остаток в полосе лимита — `Budgets.html` (.stack)
        static let defaultStripeWidth: CGFloat = 5
        /// Фон пустого состояния — `BudgetsEmpty.html`
        static let wideStripeWidth: CGFloat = 8
        /// √2: ширина полосы под 45° в проекции на горизонталь
        static let diagonalFactor: CGFloat = 2.squareRoot()
    }
}

// MARK: - Previews

#if DEBUG
private struct HatchPatternGallery: View {

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Полоса 5 · остаток") {
                HatchPattern()
                    .frame(height: 22)
                    .brutalBorder(radius: 8)
            }
            DSPreviewCase("Полоса 8 · пустое состояние") {
                HatchPattern(stripeWidth: HatchPattern.Metrics.wideStripeWidth)
                    .frame(height: 120)
                    .brutalBorder(radius: DS.Radius.card)
            }
        }
    }
}

#Preview("Светлая") {
    HatchPatternGallery()
}

#Preview("Темная") {
    HatchPatternGallery()
        .preferredColorScheme(.dark)
}
#endif

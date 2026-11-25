//
//  ProgressBar.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Полоса прогресса бюджета или лимита.
/// Превышение (progress > 1) — вся полоса в красной штриховке.
/// Необязательная метка темпа показывает, сколько «положено» потратить к сегодняшнему дню
struct ProgressBar: View {

    // MARK: - Types

    enum Size {
        /// Бюджеты категорий — 14 pt
        case regular
        /// Карточка «Можно потратить сегодня» — 12 pt
        case compact

        var height: CGFloat {
            switch self {
            case .regular: return Metrics.regularHeight
            case .compact: return Metrics.compactHeight
            }
        }
    }

    // MARK: - Properties

    /// Доля потраченного: 0…1, больше 1 — превышение
    let progress: Double
    var tint: Color = DS.Color.ink
    /// Положение метки темпа, 0…1; nil — без метки
    var paceMarker: Double?
    var size: Size = .regular

    // MARK: - Computed Properties

    var isOver: Bool {
        progress > 1
    }

    private var clampedProgress: Double {
        min(max(progress, .zero), 1)
    }

    private var radius: CGFloat {
        size.height / 2
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                if isOver {
                    OverStripes()
                } else {
                    fill(width: proxy.size.width * clampedProgress)
                }
            }
            .frame(width: proxy.size.width, height: size.height, alignment: .leading)
            .background(DS.Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .brutalBorder(radius: radius)
            .overlay(alignment: .leading) {
                if let paceMarker, !isOver {
                    marker(at: proxy.size.width * min(max(paceMarker, .zero), 1))
                }
            }
        }
        .frame(height: size.height)
        .accessibilityElement()
        .accessibilityValue(Text(progress, format: .percent.precision(.fractionLength(0))))
    }
}

// MARK: - Subviews

private extension ProgressBar {

    func fill(width: CGFloat) -> some View {
        Rectangle()
            .fill(tint)
            .frame(width: width)
            .overlay(alignment: .trailing) {
                // Правый край заливки отделен обводкой, как в макете
                if width > .zero && clampedProgress < 1 {
                    Rectangle()
                        .fill(DS.Color.ink)
                        .frame(width: DS.Stroke.regular)
                }
            }
    }

    func marker(at x: CGFloat) -> some View {
        Rectangle()
            .fill(DS.Color.ink)
            .frame(width: Metrics.markerWidth, height: size.height + Metrics.markerOverhang * 2)
            .offset(x: x - Metrics.markerWidth / 2)
    }
}

// MARK: - Over Stripes

/// Диагональная штриховка −45°: полосы по 6 pt двух красных тонов
private struct OverStripes: View {

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(DS.Color.overStripeSoft))

            let period = Metrics.stripeWidth * 2
            // Сдвиг вдоль оси X: линия под 45° пересекает высоту за size.height
            var x = -size.height
            while x < size.width + size.height {
                var stripe = Path()
                stripe.move(to: CGPoint(x: x, y: size.height))
                stripe.addLine(to: CGPoint(x: x + size.height, y: .zero))
                stripe.addLine(to: CGPoint(x: x + size.height + stripeBase, y: .zero))
                stripe.addLine(to: CGPoint(x: x + stripeBase, y: size.height))
                stripe.closeSubpath()
                context.fill(stripe, with: .color(DS.Color.overStripeStrong))
                x += period * Metrics.diagonalFactor
            }
        }
    }

    /// Ширина полосы по горизонтали: 6 pt по нормали к наклону 45°
    private var stripeBase: CGFloat {
        Metrics.stripeWidth * Metrics.diagonalFactor
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/Budgets.html` (.prog) и `Main.html` (.bar)
    static let regularHeight: CGFloat = 14
    static let compactHeight: CGFloat = 12
    static let markerWidth: CGFloat = 2
    static let markerOverhang: CGFloat = 2
    static let stripeWidth: CGFloat = 6
    /// √2: проекция ширины полосы на горизонталь при наклоне 45°
    static let diagonalFactor: CGFloat = 2.squareRoot()
}

// MARK: - Previews

#if DEBUG
private struct ProgressBarGallery: View {

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Пусто · 0%") {
                ProgressBar(progress: 0, tint: DS.CategoryColor.blue.color)
            }
            DSPreviewCase("46% · метка темпа") {
                ProgressBar(progress: 0.465, tint: DS.CategoryColor.blue.color, paceMarker: 0.633)
            }
            DSPreviewCase("81% · обгоняет темп") {
                ProgressBar(progress: 0.812, tint: DS.CategoryColor.purple.color, paceMarker: 0.633)
            }
            DSPreviewCase("Ровно 100%") {
                ProgressBar(progress: 1, tint: DS.CategoryColor.green.color)
            }
            DSPreviewCase("Over · 114%") {
                ProgressBar(progress: 1.14, tint: DS.CategoryColor.orange.color, paceMarker: 0.633)
            }
            DSPreviewCase("Compact · ink · 61%") {
                ProgressBar(progress: 0.61, size: .compact)
            }
        }
    }
}

#Preview("Светлая") {
    ProgressBarGallery()
}

#Preview("Темная") {
    ProgressBarGallery()
        .preferredColorScheme(.dark)
}
#endif

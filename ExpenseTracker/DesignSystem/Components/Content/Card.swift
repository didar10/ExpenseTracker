//
//  Card.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Карточка: заливка surface, обводка ink, радиус 14, без тени.
/// Для списков — `padding: nil` и `ListDivider` между строками
struct Card<Content: View>: View {

    // MARK: - Types

    enum Style {
        case solid
        /// Пустое состояние: прозрачная, пунктирная обводка
        case dashed
    }

    // MARK: - Properties

    var style: Style = .solid
    /// nil — без внутренних отступов: строки списка задают их сами
    var padding: EdgeInsets? = Card.defaultPadding
    @ViewBuilder let content: Content

    // MARK: - Init

    init(style: Style = .solid, padding: EdgeInsets? = Card.defaultPadding, @ViewBuilder content: () -> Content) {
        self.style = style
        self.padding = padding
        self.content = content()
    }

    // MARK: - Body

    var body: some View {
        content
            .padding(padding ?? EdgeInsets())
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card))
            .overlay { border }
    }
}

extension Card {

    /// Отступы карточки «Можно потратить сегодня»: 14 по вертикали, 16 по горизонтали
    static var defaultPadding: EdgeInsets {
        EdgeInsets(top: Metrics.verticalPadding, leading: DS.Spacing.lg, bottom: Metrics.verticalPadding, trailing: DS.Spacing.lg)
    }
}

// MARK: - Subviews

private extension Card {

    var background: Color {
        switch style {
        case .solid: return DS.Color.surface
        case .dashed: return .clear
        }
    }

    @ViewBuilder
    var border: some View {
        let shape = RoundedRectangle(cornerRadius: DS.Radius.card)

        switch style {
        case .solid:
            shape.strokeBorder(DS.Color.ink, lineWidth: DS.Stroke.regular)
        case .dashed:
            shape.strokeBorder(DS.Color.ink, style: StrokeStyle(lineWidth: DS.Stroke.regular, dash: DS.Stroke.dash))
        }
    }
}

// MARK: - Metrics

private enum Metrics {
    static let verticalPadding: CGFloat = 14
}

/// Разделитель строк внутри карточки-списка: 1 pt цвета line
struct ListDivider: View {

    var body: some View {
        Rectangle()
            .fill(DS.Color.line)
            .frame(height: DS.Stroke.hairline)
    }
}

// MARK: - Previews

#if DEBUG
private struct CardGallery: View {

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Solid") {
                Card {
                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        Text("Можно потратить сегодня").dsLabel()
                        Text("4 413 ₸").font(DS.Font.screenTitle).foregroundStyle(DS.Color.ink)
                        ProgressBar(progress: 0.61, size: .compact)
                    }
                }
            }
            DSPreviewCase("Список без отступов") {
                Card(padding: nil) {
                    VStack(spacing: .zero) {
                        Text("Строка 1").padding(DS.Spacing.lg)
                        ListDivider()
                        Text("Строка 2").padding(DS.Spacing.lg)
                    }
                    .foregroundStyle(DS.Color.ink)
                }
            }
            DSPreviewCase("Dashed · пустое состояние") {
                Card(style: .dashed) {
                    VStack(spacing: DS.Spacing.sm) {
                        Text("Операций пока нет").font(DS.Font.sheetTitle).foregroundStyle(DS.Color.ink)
                        Text("Запишите первый расход — баланс обновится сразу")
                            .font(DS.Font.body)
                            .foregroundStyle(DS.Color.ink2)
                            .multilineTextAlignment(.center)
                        PrimaryButton(title: "Добавить расход", icon: Image(systemName: "plus")) {}
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

#Preview("Светлая") {
    CardGallery()
}

#Preview("Темная") {
    CardGallery()
        .preferredColorScheme(.dark)
}
#endif

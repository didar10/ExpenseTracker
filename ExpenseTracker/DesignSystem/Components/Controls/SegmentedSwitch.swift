//
//  SegmentedSwitch.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Переключатель из равных сегментов: Расходы | Доходы, Карта | Наличные | Вклад.
/// Выбранный сегмент залит accent (или ink — период бюджета), сегменты разделены обводкой
struct SegmentedSwitch<Value: Hashable>: View {

    // MARK: - Types

    struct Option {
        let value: Value
        let title: String
        /// Иконка перед названием: ↗ Расходы / ↙ Доходы в статистике
        var icon: Image?
        /// false — сегмент виден, но не выбирается
        var isEnabled = true
    }

    /// Заливка выбранного сегмента
    enum Fill {
        case accent
        /// Черная заливка, светлый текст — `AddBudget.html` (.periodS)
        case ink

        fileprivate var background: Color {
            switch self {
            case .accent: return DS.Color.accent
            case .ink: return DS.Color.ink
            }
        }

        fileprivate var foreground: Color {
            switch self {
            case .accent: return DS.Color.onAccent
            case .ink: return DS.Color.bg
            }
        }
    }

    /// Размер подписей
    enum LabelSize {
        /// SF Bold 15
        case regular
        /// SF Bold 14 — три длинные опции в узкой шапке: «Расход | Доход | Перевод»
        case compact
    }

    // MARK: - Properties

    @Binding var selection: Value
    let options: [Option]
    var fill: Fill = .accent
    var labelSize: LabelSize = .regular

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Системного стиля размера 14 нет: размер масштабируется Dynamic Type вручную
    @ScaledMetric(relativeTo: .subheadline) private var compactFontSize = DS.Font.Size.segmentCompact

    // MARK: - Computed Properties

    private var labelFont: Font {
        switch labelSize {
        case .regular: return DS.Font.controlBold
        case .compact: return .system(size: compactFontSize, weight: .bold)
        }
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: .zero) {
            ForEach(Array(options.enumerated()), id: \.element.value) { index, option in
                if index > .zero {
                    Rectangle()
                        .fill(DS.Color.ink)
                        .frame(width: DS.Stroke.regular)
                }

                segment(option)
            }
        }
        .frame(minHeight: DS.Size.control)
        .fixedSize(horizontal: false, vertical: true)
        .background(DS.Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.control))
        .brutalBorder(radius: DS.Radius.control)
        .animation(reduceMotion ? nil : DS.Motion.toggle, value: selection)
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Subviews

private extension SegmentedSwitch {

    func segment(_ option: Option) -> some View {
        let isSelected = option.value == selection

        return Button {
            selection = option.value
        } label: {
            HStack(spacing: Constants.iconSpacing) {
                if let icon = option.icon {
                    icon
                        .font(.system(size: DS.Size.iconXS, weight: .bold))
                        .accessibilityHidden(true)
                }

                Text(option.title)
                    .font(labelFont)
                    .lineLimit(1)
                    .minimumScaleFactor(Constants.minimumScale)
            }
            .foregroundStyle(isSelected ? fill.foreground : DS.Color.ink2)
            .padding(.horizontal, DS.Spacing.sm)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(isSelected ? fill.background : .clear)
        }
        .buttonStyle(.outlineClickSegment)
        .disabled(!option.isEnabled)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Constants

private enum Constants {
    static let minimumScale: CGFloat = 0.8
    /// Иконка и название — `Statistics.html` (gap 6)
    static let iconSpacing: CGFloat = 6
}

// MARK: - Previews

#if DEBUG
private struct SegmentedSwitchGallery: View {

    @State private var type = "expense"
    @State private var kind = "cash"

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Два сегмента · выбран первый") {
                SegmentedSwitch(selection: $type, options: [
                    .init(value: "expense", title: "Расходы"),
                    .init(value: "income", title: "Доходы")
                ])
            }
            DSPreviewCase("С иконками · статистика") {
                SegmentedSwitch(selection: $type, options: [
                    .init(value: "expense", title: "Расходы", icon: Image(systemName: "arrow.up.right")),
                    .init(value: "income", title: "Доходы", icon: Image(systemName: "arrow.down.left"))
                ])
            }
            DSPreviewCase("Три сегмента · выбран средний") {
                SegmentedSwitch(selection: $kind, options: [
                    .init(value: "card", title: "Карта"),
                    .init(value: "cash", title: "Наличные"),
                    .init(value: "deposit", title: "Вклад")
                ])
            }
            DSPreviewCase("Три сегмента · компактные подписи") {
                SegmentedSwitch(selection: $type, options: [
                    .init(value: "expense", title: "Расход"),
                    .init(value: "income", title: "Доход"),
                    .init(value: "transfer", title: "Перевод")
                ], labelSize: .compact)
            }
            DSPreviewCase("Disabled") {
                SegmentedSwitch(selection: .constant("week"), options: [
                    .init(value: "week", title: "Неделя"),
                    .init(value: "month", title: "Месяц"),
                    .init(value: "year", title: "Год")
                ])
                .disabled(true)
            }
        }
    }
}

#Preview("Светлая") {
    SegmentedSwitchGallery()
}

#Preview("Темная") {
    SegmentedSwitchGallery()
        .preferredColorScheme(.dark)
}
#endif

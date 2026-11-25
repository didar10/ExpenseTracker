//
//  SegmentedSwitch.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Переключатель из равных сегментов: Расходы | Доходы, Карта | Наличные | Вклад.
/// Выбранный сегмент залит accent, сегменты разделены обводкой
struct SegmentedSwitch<Value: Hashable>: View {

    // MARK: - Types

    struct Option {
        let value: Value
        let title: String
    }

    // MARK: - Properties

    @Binding var selection: Value
    let options: [Option]

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
    }
}

// MARK: - Subviews

private extension SegmentedSwitch {

    func segment(_ option: Option) -> some View {
        let isSelected = option.value == selection

        return Button {
            selection = option.value
        } label: {
            Text(option.title)
                .font(DS.Font.controlBold)
                .foregroundStyle(isSelected ? DS.Color.onAccent : DS.Color.ink2)
                .lineLimit(1)
                .minimumScaleFactor(Constants.minimumScale)
                .padding(.horizontal, DS.Spacing.sm)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isSelected ? DS.Color.accent : .clear)
        }
        .buttonStyle(.outlineClickSegment)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Constants

private enum Constants {
    static let minimumScale: CGFloat = 0.8
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
            DSPreviewCase("Три сегмента · выбран средний") {
                SegmentedSwitch(selection: $kind, options: [
                    .init(value: "card", title: "Карта"),
                    .init(value: "cash", title: "Наличные"),
                    .init(value: "deposit", title: "Вклад")
                ])
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

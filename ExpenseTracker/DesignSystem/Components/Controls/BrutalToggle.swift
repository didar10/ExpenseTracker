//
//  BrutalToggle.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Строка с переключателем: заголовок, необязательная подпись и квадратный тумблер справа.
/// Это настоящий `Toggle` — VoiceOver читает его как переключатель
struct BrutalToggle: View {

    // MARK: - Properties

    let title: String
    var subtitle: String?
    @Binding var isOn: Bool

    // MARK: - Init

    init(_ title: String, subtitle: String? = nil, isOn: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }

    // MARK: - Body

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: DS.Spacing.xs / 2) {
                Text(title)
                    .font(DS.Font.bodyBold)
                    .foregroundStyle(DS.Color.ink)

                if let subtitle {
                    Text(subtitle)
                        .font(DS.Font.caption)
                        .foregroundStyle(DS.Color.ink2)
                }
            }
        }
        .toggleStyle(.brutal)
    }
}

// MARK: - Toggle Style

/// Квадратный тумблер 51×31: выключен — фон bg, включен — accent; ручка — белый квадрат с обводкой
struct BrutalToggleStyle: ToggleStyle {

    func makeBody(configuration: Configuration) -> some View {
        BrutalToggleBody(configuration: configuration)
    }
}

extension ToggleStyle where Self == BrutalToggleStyle {

    static var brutal: BrutalToggleStyle {
        BrutalToggleStyle()
    }
}

private struct BrutalToggleBody: View {

    // MARK: - Properties

    let configuration: ToggleStyleConfiguration

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Body

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            configuration.label
                .frame(maxWidth: .infinity, alignment: .leading)

            track
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard isEnabled else { return }
            configuration.isOn.toggle()
        }
        .opacity(isEnabled ? 1 : Metrics.disabledOpacity)
        .animation(reduceMotion ? nil : DS.Motion.toggle, value: configuration.isOn)
    }

    private var track: some View {
        RoundedRectangle(cornerRadius: Metrics.trackRadius)
            .fill(configuration.isOn ? DS.Color.accent : DS.Color.bg)
            .frame(width: Metrics.trackWidth, height: Metrics.trackHeight)
            .brutalBorder(radius: Metrics.trackRadius)
            .overlay(alignment: configuration.isOn ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: Metrics.knobRadius)
                    .fill(DS.Color.surface)
                    .frame(width: Metrics.knob, height: Metrics.knob)
                    .brutalBorder(radius: Metrics.knobRadius)
                    .padding(Metrics.knobInset)
            }
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/Main.html` (.tg)
    static let trackWidth: CGFloat = 51
    static let trackHeight: CGFloat = 31
    static let trackRadius: CGFloat = 9
    static let knob: CGFloat = 24
    static let knobRadius: CGFloat = 6
    /// 2 pt от внутреннего края обводки
    static let knobInset: CGFloat = 2 + DS.Stroke.regular
    static let disabledOpacity: Double = 0.4
}

// MARK: - Previews

#if DEBUG
private struct BrutalToggleGallery: View {

    @State private var isOn = true
    @State private var isOff = false

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Включен") {
                BrutalToggle("Счёт по умолчанию", subtitle: "Будет выбран при создании операций", isOn: $isOn)
            }
            DSPreviewCase("Выключен") {
                BrutalToggle("Лимит на главной", isOn: $isOff)
            }
            DSPreviewCase("Disabled") {
                BrutalToggle("Недоступно", subtitle: "Нужен хотя бы один счёт", isOn: .constant(false))
                    .disabled(true)
            }
        }
    }
}

#Preview("Светлая") {
    BrutalToggleGallery()
}

#Preview("Темная") {
    BrutalToggleGallery()
        .preferredColorScheme(.dark)
}
#endif

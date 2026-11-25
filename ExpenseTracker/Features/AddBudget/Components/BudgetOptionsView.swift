//
//  BudgetOptionsView.swift
//  ExpenseTracker
//
//  Created by Didar on 26.11.2026.
//

import SwiftUI

/// «Переносить остаток» и «Предупредить на 80%».
/// Обычно — карточка из двух строк с `BrutalToggle`; на низком экране (iPhone SE) —
/// одна строка из двух чипов-переключателей: так лист обходится без прокрутки
struct BudgetOptionsView: View {

    // MARK: - Properties

    @Binding var carriesOverRemainder: Bool
    @Binding var warnsNearLimit: Bool
    var isCompact = false

    // MARK: - Body

    var body: some View {
        if isCompact {
            HStack(spacing: DS.Spacing.sm) {
                Toggle(AppString.addBudgetCarryOver, isOn: $carriesOverRemainder)
                Toggle(AppString.addBudgetWarnNearLimit, isOn: $warnsNearLimit)
            }
            .toggleStyle(ChipToggleStyle())
        } else {
            Card(padding: nil) {
                VStack(spacing: .zero) {
                    row(AppString.addBudgetCarryOver, isOn: $carriesOverRemainder)
                    ListDivider()
                    row(AppString.addBudgetWarnNearLimit, isOn: $warnsNearLimit)
                }
            }
        }
    }
}

// MARK: - Subviews

private extension BudgetOptionsView {

    func row(_ title: String, isOn: Binding<Bool>) -> some View {
        BrutalToggle(title, isOn: isOn)
            .padding(.vertical, DS.Spacing.xs)
            .padding(.horizontal, DS.Spacing.md)
            .frame(minHeight: Metrics.rowHeight)
    }
}

// MARK: - Chip Toggle

/// Чип-переключатель: включен — accent, выключен — surface. Обводка без тени
private struct ChipToggleStyle: ToggleStyle {

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.label
                .font(DS.Font.captionBold)
                .lineLimit(1)
                .minimumScaleFactor(Metrics.chipMinimumScale)
                .padding(.horizontal, Metrics.chipPadding)
                .frame(maxWidth: .infinity, minHeight: DS.Size.control)
        }
        .buttonStyle(OutlineClickStyle(
            shape: .bordered(radius: DS.Radius.control),
            fill: configuration.isOn ? DS.Color.accent : DS.Color.surface,
            foreground: configuration.isOn ? DS.Color.onAccent : DS.Color.ink2
        ))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isToggle)
        .accessibilityValue(configuration.isOn ? AppString.toggleOn : AppString.toggleOff)
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/AddBudget.html` (.li: min-height 46, padding 4 12)
    static let rowHeight: CGFloat = 46
    static let chipPadding: CGFloat = 10
    static let chipMinimumScale: CGFloat = 0.75
}

// MARK: - Previews

#if DEBUG
private struct BudgetOptionsPreview: View {

    @State private var carryOver = true
    @State private var warn = false

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Карточка") {
                BudgetOptionsView(carriesOverRemainder: $carryOver, warnsNearLimit: $warn)
            }
            DSPreviewCase("iPhone SE · одна строка") {
                BudgetOptionsView(carriesOverRemainder: $carryOver, warnsNearLimit: $warn, isCompact: true)
            }
        }
    }
}

#Preview("Светлая") {
    BudgetOptionsPreview()
}

#Preview("Темная") {
    BudgetOptionsPreview()
        .preferredColorScheme(.dark)
}
#endif

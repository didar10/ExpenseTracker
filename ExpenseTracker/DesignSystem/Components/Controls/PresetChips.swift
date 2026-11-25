//
//  PresetChips.swift
//  ExpenseTracker
//
//  Created by Didar on 26.11.2026.
//

import SwiftUI

/// Пресет суммы: «150 000» или «Октябрь 18 400»
struct PresetChip: Identifiable, Equatable {

    // MARK: - Properties

    let id: String
    /// Подпись перед суммой; nil — только сумма
    var title: String?
    /// nil — суммы нет (не выбрана категория, не было трат): чип неактивен
    let amount: Decimal?
}

/// Быстрые суммы: высота 34, радиус 10, выбранная — accent, без тени.
/// `fillsWidth` — чипы делят ширину поровну и ужимают текст, а не переносят
struct PresetChips: View {

    // MARK: - Properties

    let chips: [PresetChip]
    let isSelected: (PresetChip) -> Bool
    var fillsWidth = false
    let onSelect: (Decimal) -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: Metrics.spacing) {
            ForEach(chips) { chip in
                chipButton(chip)
            }
        }
    }
}

// MARK: - Subviews

private extension PresetChips {

    func chipButton(_ chip: PresetChip) -> some View {
        let selected = chip.amount != nil && isSelected(chip)

        return Button {
            if let amount = chip.amount { onSelect(amount) }
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: Metrics.spacing) {
                if let title = chip.title {
                    Text(title)
                        .font(DS.Font.captionBold)
                }

                if let amount = chip.amount {
                    Text(MoneyFormat.number(amount))
                        .font(chip.title == nil ? DS.Font.captionBold : DS.Font.moneySmall)
                        .foregroundStyle(amountColor(chip, isSelected: selected))
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(Metrics.minimumScale)
            .padding(.horizontal, Metrics.horizontalPadding)
            .frame(maxWidth: fillsWidth ? .infinity : nil, minHeight: Metrics.height)
        }
        .buttonStyle(OutlineClickStyle(
            shape: .bordered(radius: Metrics.radius),
            fill: selected ? DS.Color.accent : DS.Color.surface,
            foreground: selected ? DS.Color.onAccent : DS.Color.ink
        ))
        .disabled(chip.amount == nil || chip.amount == 0)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    /// Сумма после подписи — ink2; на выбранном чипе и без подписи — основной цвет
    func amountColor(_ chip: PresetChip, isSelected: Bool) -> Color {
        if isSelected { return DS.Color.onAccent }
        return chip.title == nil ? DS.Color.ink : DS.Color.ink2
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/MonthlyLimit.html` и `AddBudget.html` (.preset)
    static let height: CGFloat = 34
    static let horizontalPadding: CGFloat = 9
    static let radius: CGFloat = 10
    static let spacing: CGFloat = 6
    static let minimumScale: CGFloat = 0.7
}

// MARK: - Previews

#if DEBUG
private struct PresetChipsGallery: View {

    private let limits = [150_000, 250_000, 300_000].map { PresetChip(id: "\($0)", amount: Decimal($0)) }
    private let budget = [
        PresetChip(id: "last", title: "Октябрь", amount: 18_400),
        PresetChip(id: "minus", title: "−10%", amount: 16_600),
        PresetChip(id: "avg", title: "3 мес", amount: 19_900)
    ]

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Лимит · ничего не выбрано") {
                PresetChips(chips: limits, isSelected: { _ in false }) { _ in }
            }
            DSPreviewCase("Лимит · выбран 250 000") {
                PresetChips(chips: limits, isSelected: { $0.amount == 250_000 }) { _ in }
            }
            DSPreviewCase("Бюджет · на всю ширину, выбран «Октябрь»") {
                PresetChips(chips: budget, isSelected: { $0.id == "last" }, fillsWidth: true) { _ in }
            }
            DSPreviewCase("Бюджет · без категории") {
                PresetChips(chips: budget.map { PresetChip(id: $0.id, title: $0.title, amount: nil) }, isSelected: { _ in false }, fillsWidth: true) { _ in }
            }
        }
    }
}

#Preview("Светлая") {
    PresetChipsGallery()
}

#Preview("Темная") {
    PresetChipsGallery()
        .preferredColorScheme(.dark)
}
#endif

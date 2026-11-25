//
//  MonthlyLimitView.swift
//  ExpenseTracker
//
//  Created by Didar on 26.11.2026.
//

import SwiftUI

extension View {

    /// Лист «Лимит на месяц» поверх экрана: из «Бюджетов» и с карточки «Можно потратить сегодня»
    func monthlyLimitSheet(isPresented: Binding<Bool>, limitStore: MonthlyLimitStore) -> some View {
        brutalSheet(
            isPresented: isPresented,
            title: AppString.monthlyLimitTitle,
            actionTitle: AppString.cancel,
            detents: [.large]
        ) {
            MonthlyLimitView(limitStore: limitStore)
        }
    }
}

/// Содержимое листа: пояснение, сумма с ₸ и суммой на день, пресеты, клавиатура 3×4,
/// «Сохранить» и, если лимит уже задан, «Убрать лимит».
/// Заголовок и «Отмена» рисует `BrutalSheetLayout`
struct MonthlyLimitView: View {

    // MARK: - Properties

    @State private var viewModel: MonthlyLimitViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Init

    init(limitStore: MonthlyLimitStore) {
        _viewModel = State(initialValue: MonthlyLimitViewModel(limitStore: limitStore))
    }

    init(viewModel: MonthlyLimitViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            Text(AppString.monthlyLimitDescription)
                .font(DS.Font.caption)
                .foregroundStyle(DS.Color.ink2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            amount
                .padding(.top, Metrics.descriptionBottom)

            perDay
                .padding(.top, DS.Spacing.xs)

            PresetChips(
                chips: viewModel.presets.map { PresetChip(id: MoneyFormat.number($0), amount: $0) },
                isSelected: { $0.amount.map(viewModel.isSelected) ?? false },
                onSelect: viewModel.selectPreset
            )
                .padding(.top, DS.Spacing.md)

            Spacer(minLength: DS.Spacing.md)

            CalculatorKeypad(layout: .amount, onKey: viewModel.press)

            actions
                .padding(.top, DS.Spacing.md)
        }
        .padding(.bottom, DS.Spacing.sm)
        .sensoryFeedback(.selection, trigger: viewModel.digits)
    }
}

// MARK: - Subviews

private extension MonthlyLimitView {

    var amount: some View {
        HStack(alignment: .firstTextBaseline, spacing: DS.Spacing.sm) {
            Text(MoneyFormat.number(viewModel.amount))
                .font(DS.Font.amountXL)
                .foregroundStyle(viewModel.isEmpty ? DS.Color.ink2 : DS.Color.ink)
                .lineLimit(1)
                .minimumScaleFactor(Metrics.amountMinimumScale)
                .contentTransition(.numericText())
                .animation(reduceMotion ? nil : DS.Motion.press, value: viewModel.digits)

            Text(AppString.currencySymbol)
                .font(DS.Font.amountSignS)
                .foregroundStyle(DS.Color.ink2)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(AccessibilityID.monthlyLimitAmount)
    }

    /// Пустая строка держит высоту, чтобы пресеты не прыгали при вводе первой цифры
    var perDay: some View {
        Text(viewModel.perDay.map { AppString.monthlyLimitPerDayHint(MoneyFormat.money($0)) } ?? AppString.currencySymbol)
            .font(DS.Font.moneySmall)
            .foregroundStyle(DS.Color.ink2)
            .opacity(viewModel.perDay == nil ? .zero : 1)
            .accessibilityHidden(viewModel.perDay == nil)
    }

    var actions: some View {
        VStack(spacing: Metrics.buttonSpacing) {
            PrimaryButton(title: viewModel.saveButtonTitle, action: save)
                .disabled(!viewModel.canSave)

            if viewModel.hasLimit {
                Button(action: removeLimit) {
                    Text(AppString.removeMonthlyLimit)
                        .font(DS.Font.buttonSmall)
                        .frame(maxWidth: .infinity, minHeight: DS.Size.menuRow)
                }
                .buttonStyle(.outlineClickDanger)
            }
        }
    }
}

// MARK: - Actions

private extension MonthlyLimitView {

    func save() {
        viewModel.save()
        dismiss()
    }

    func removeLimit() {
        viewModel.removeLimit()
        dismiss()
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/MonthlyLimit.html`
    static let descriptionBottom: CGFloat = 14
    static let buttonSpacing: CGFloat = 10
    static let amountMinimumScale: CGFloat = 0.5
}

// MARK: - Previews

#if DEBUG
private struct MonthlyLimitPreview: View {

    var limit: Decimal?

    var body: some View {
        let store = MonthlyLimitStore(defaults: UserDefaults(suiteName: UUID().uuidString) ?? .standard)
        store.setLimit(limit)

        return BrutalSheetLayout(title: AppString.monthlyLimitTitle, actionTitle: AppString.cancel) {
            MonthlyLimitView(limitStore: store)
        }
    }
}

#Preview("Пусто · светлая") {
    MonthlyLimitPreview()
}

#Preview("Пусто · темная") {
    MonthlyLimitPreview()
        .preferredColorScheme(.dark)
}

#Preview("Лимит задан · светлая") {
    MonthlyLimitPreview(limit: 250_000)
}

#Preview("Лимит задан · темная") {
    MonthlyLimitPreview(limit: 250_000)
        .preferredColorScheme(.dark)
}

#Preview("Лист поверх экрана") {
    let fixture = FixtureEnvironment(.sample)

    BudgetsView(limitStore: fixture.limitStore)
        .monthlyLimitSheet(isPresented: .constant(true), limitStore: fixture.limitStore)
        .fixture(fixture)
}
#endif

//
//  DatePickerSheetContent.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Содержимое листа «Дата»: чипы Сегодня / Вчера / Позавчера, календарь без будущих дней,
/// время шагом 15 минут и «Готово». Изменения применяются только по «Готово»
struct DatePickerSheetContent: View {

    // MARK: - Properties

    let onDone: (Date) -> Void

    @State private var date: Date
    @State private var month: Date

    private let rules: TransactionDateRules

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Init

    init(date: Date, rules: TransactionDateRules = TransactionDateRules(), onDone: @escaping (Date) -> Void) {
        self.rules = rules
        self.onDone = onDone
        self._date = State(initialValue: date)
        self._month = State(initialValue: rules.monthStart(of: date))
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: .zero) {
                quickDays

                calendarCard
                    .padding(.top, DS.Spacing.md)

                timeRow
                    .padding(.top, DS.Spacing.md)

                PrimaryButton(title: AppString.done) {
                    onDone(date)
                }
                .padding(.top, Metrics.doneTop)
            }
            .padding(.bottom, DS.Spacing.sm)
        }
        .scrollBounceBehavior(.basedOnSize)
        .sensoryFeedback(.selection, trigger: date)
    }
}

// MARK: - Quick Days

private extension DatePickerSheetContent {

    var quickDays: some View {
        HStack(spacing: DS.Spacing.sm) {
            ForEach(QuickDay.allCases) { quickDay in
                let isSelected = rules.quickDay(of: date) == quickDay

                Button {
                    select(rules.date(for: quickDay, keepingTimeOf: date))
                } label: {
                    Text(quickDay.title)
                        .font(DS.Font.control)
                        .lineLimit(1)
                        .minimumScaleFactor(Metrics.minimumScale)
                        .padding(.horizontal, DS.Spacing.xs)
                        .frame(maxWidth: .infinity, minHeight: DS.Size.control)
                }
                .buttonStyle(OutlineClickStyle(
                    shape: .bordered(radius: DS.Radius.control),
                    fill: isSelected ? DS.Color.accent : DS.Color.surface,
                    foreground: isSelected ? DS.Color.onAccent : DS.Color.ink
                ))
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}

// MARK: - Calendar

private extension DatePickerSheetContent {

    var calendarCard: some View {
        VStack(spacing: DS.Spacing.sm) {
            monthHeader

            LazyVGrid(columns: Metrics.columns, spacing: DS.Spacing.xs) {
                ForEach(Array(rules.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .dsLabel()
                        .frame(minHeight: Metrics.weekdayHeight)
                        .accessibilityHidden(true)
                }

                ForEach(Array(rules.days(inMonthOf: month).enumerated()), id: \.offset) { _, day in
                    if let day {
                        dayCell(day)
                    } else {
                        Color.clear
                            .frame(height: Metrics.dayHeight)
                            .accessibilityHidden(true)
                    }
                }
            }
        }
        .padding(.horizontal, Metrics.cardPadding)
        .padding(.top, Metrics.cardPadding)
        .padding(.bottom, DS.Spacing.md)
        .background(DS.Color.surface, in: RoundedRectangle(cornerRadius: DS.Radius.card))
        .brutalBorder(radius: DS.Radius.card)
    }

    var monthHeader: some View {
        HStack {
            monthButton(icon: DS.Icon.chevronLeft, label: AppString.previousMonth, offset: -1, isEnabled: true)

            Text(rules.monthTitle(for: month))
                .font(DS.Font.monthTitle)
                .foregroundStyle(DS.Color.ink)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)

            monthButton(icon: DS.Icon.chevronRight, label: AppString.nextMonth, offset: 1, isEnabled: rules.canShowMonth(after: month))
        }
    }

    func monthButton(icon: Image, label: String, offset: Int, isEnabled: Bool) -> some View {
        Button {
            guard let next = rules.calendar.date(byAdding: .month, value: offset, to: month) else { return }
            withAnimation(reduceMotion ? nil : DS.Motion.toggle) {
                month = rules.monthStart(of: next)
            }
        } label: {
            icon
                .font(.system(size: DS.Size.iconM, weight: .semibold))
                .frame(width: Metrics.monthButton, height: Metrics.monthButton)
        }
        .buttonStyle(OutlineClickStyle(shape: .segment(radius: Metrics.dayRadius), fill: .clear))
        .disabled(!isEnabled)
        .accessibilityLabel(label)
    }

    func dayCell(_ day: Date) -> some View {
        let calendar = rules.calendar
        let isSelected = calendar.isDate(day, inSameDayAs: date)
        let isToday = calendar.isDate(day, inSameDayAs: rules.now)
        let isSelectable = rules.isSelectable(day: day)
        let shape = RoundedRectangle(cornerRadius: Metrics.dayRadius)

        return Button {
            select(rules.date(onDay: day, keepingTimeOf: date))
        } label: {
            Text(String(calendar.component(.day, from: day)))
                .font(DS.Font.calendarDay)
                .fontWeight(isSelected ? .bold : nil)
                .foregroundStyle(foreground(isSelected: isSelected, isSelectable: isSelectable))
                .frame(maxWidth: .infinity, minHeight: Metrics.dayHeight)
                .background(isSelected ? DS.Color.accent : .clear, in: shape)
                .overlay {
                    if isSelected || isToday {
                        shape.strokeBorder(DS.Color.ink, lineWidth: DS.Stroke.regular)
                    }
                }
                .contentShape(shape)
        }
        // Выбранный день и сегодня обводит сама метка, щелчок добавляет заливку и обводку 2.5 pt
        .buttonStyle(OutlineClickStyle(shape: .segment(radius: Metrics.dayRadius), fill: .clear))
        .disabled(!isSelectable)
        .accessibilityLabel(day.formatted(date: .complete, time: .omitted))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    func foreground(isSelected: Bool, isSelectable: Bool) -> Color {
        if isSelected { return DS.Color.onAccent }
        return isSelectable ? DS.Color.ink : DS.Color.inkDisabled
    }
}

// MARK: - Time

private extension DatePickerSheetContent {

    var timeRow: some View {
        HStack(spacing: Metrics.timeSpacing) {
            Text(AppString.time)
                .font(DS.Font.control)
                .frame(maxWidth: .infinity, alignment: .leading)

            stepButton(icon: DS.Icon.minus, label: AppString.timeEarlier, forward: false)

            Text(rules.timeText(for: date))
                .font(DS.Font.time)
                .frame(minWidth: Metrics.timeWidth)
                .accessibilityLabel(AppString.time)
                .accessibilityValue(rules.timeText(for: date))

            stepButton(icon: DS.Icon.plus, label: AppString.timeLater, forward: true)
        }
        .foregroundStyle(DS.Color.ink)
        .padding(.leading, Metrics.timeLeading)
        .padding(.trailing, DS.Spacing.sm)
        .frame(minHeight: Metrics.timeRowHeight)
        .background(DS.Color.surface, in: RoundedRectangle(cornerRadius: DS.Radius.control))
        .brutalBorder(radius: DS.Radius.control)
    }

    func stepButton(icon: Image, label: String, forward: Bool) -> some View {
        let stepped = rules.steppedTime(of: date, forward: forward)

        return Button {
            guard let stepped else { return }
            date = stepped
        } label: {
            icon
                .font(.system(size: DS.Size.iconS, weight: .bold))
                .frame(width: Metrics.stepButton, height: Metrics.stepButton)
        }
        .buttonStyle(OutlineClickStyle(shape: .bordered(radius: Metrics.stepRadius), fill: DS.Color.bg))
        .disabled(stepped == nil)
        .accessibilityLabel(label)
    }
}

// MARK: - Actions

private extension DatePickerSheetContent {

    func select(_ newDate: Date) {
        date = newDate
        withAnimation(reduceMotion ? nil : DS.Motion.toggle) {
            month = rules.monthStart(of: newDate)
        }
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/DatePicker.html` (.qd, .cal, .cg, .trow)
    static let columns = Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.xs), count: 7)
    static let cardPadding: CGFloat = 10
    static let monthButton: CGFloat = 36
    static let weekdayHeight: CGFloat = 20
    static let dayHeight: CGFloat = 40
    static let dayRadius: CGFloat = 10
    static let timeRowHeight: CGFloat = 48
    static let timeLeading: CGFloat = 14
    static let timeSpacing: CGFloat = 6
    static let timeWidth: CGFloat = 56
    static let stepButton: CGFloat = 34
    static let stepRadius: CGFloat = 9
    static let doneTop: CGFloat = 14
    static let minimumScale: CGFloat = 0.8
}

// MARK: - Previews

#if DEBUG
private enum DatePickerPreviewData {

    static var rules: TransactionDateRules {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let now = calendar.date(from: DateComponents(year: 2026, month: 11, day: 25, hour: 23, minute: 56)) ?? .now
        return TransactionDateRules(calendar: calendar, now: now)
    }

    static var selected: Date {
        rules.calendar.date(from: DateComponents(year: 2026, month: 11, day: 19, hour: 23, minute: 56)) ?? .now
    }
}

#Preview("Выбран день · светлая") {
    BrutalSheetLayout(title: AppString.date, actionTitle: AppString.cancel) {
        DatePickerSheetContent(date: DatePickerPreviewData.selected, rules: DatePickerPreviewData.rules) { _ in }
    }
}

#Preview("Сегодня · темная") {
    BrutalSheetLayout(title: AppString.date, actionTitle: AppString.cancel) {
        DatePickerSheetContent(date: DatePickerPreviewData.rules.now, rules: DatePickerPreviewData.rules) { _ in }
    }
    .preferredColorScheme(.dark)
}
#endif

//
//  MonthlyLimitViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import Foundation

@MainActor
final class MonthlyLimitViewModel: ObservableObject {

    // MARK: - UI State

    @Published var amountText: String

    // MARK: - Properties

    private let limitStore: MonthlyLimitStore

    // MARK: - Init

    init(limitStore: MonthlyLimitStore) {
        self.limitStore = limitStore
        self.amountText = limitStore.limit.map { "\($0)" } ?? ""
    }

    // MARK: - Computed Properties

    /// Лимит уже задан — экран предлагает его убрать
    var hasLimit: Bool {
        limitStore.limit != nil
    }

    var parsedAmount: Decimal? {
        let cleaned = amountText
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: " ", with: "")
        guard let value = Decimal(string: cleaned), value > 0 else { return nil }
        return value
    }

    var canSave: Bool {
        parsedAmount != nil
    }

    var saveButtonTitle: String {
        canSave ? AppString.save : AppString.enterAmount
    }

    /// Сколько выйдет в день при равномерных тратах — подсказка под полем
    var perDayHint: String? {
        guard let parsedAmount else { return nil }

        let calendar = Calendar.current
        let daysInMonth = calendar.range(of: .day, in: .month, for: .now)?.count ?? 30
        let perDay = (parsedAmount / Decimal(daysInMonth))
            .formatted(.currency(code: AppString.currencyCode).precision(.fractionLength(0)))

        return AppString.monthlyLimitPerDayHint(perDay)
    }

    // MARK: - Actions

    func save() {
        guard let parsedAmount else { return }
        limitStore.setLimit(parsedAmount)
    }

    func removeLimit() {
        limitStore.setLimit(nil)
    }
}

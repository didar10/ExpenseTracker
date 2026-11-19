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

    /// Сумма форматируется так же, как сумма операции: 500000 → 500 000
    @Published private(set) var amount: AmountInput

    // MARK: - Properties

    private let limitStore: MonthlyLimitStore

    // MARK: - Init

    init(limitStore: MonthlyLimitStore) {
        self.limitStore = limitStore
        self.amount = AmountInput(limitStore.limit)
    }

    // MARK: - Computed Properties

    /// Лимит уже задан — экран предлагает его убрать
    var hasLimit: Bool {
        limitStore.limit != nil
    }

    var canSave: Bool {
        amount.isPositive
    }

    var saveButtonTitle: String {
        canSave ? AppString.save : AppString.enterAmount
    }

    /// Сколько выйдет в день при равномерных тратах — подсказка под полем
    var perDayHint: String? {
        guard canSave, let value = amount.value else { return nil }

        let calendar = Calendar.current
        let daysInMonth = calendar.range(of: .day, in: .month, for: .now)?.count ?? 30
        let perDay = (value / Decimal(daysInMonth))
            .formatted(.currency(code: AppString.currencyCode).precision(.fractionLength(0)))

        return AppString.monthlyLimitPerDayHint(perDay)
    }

    // MARK: - Actions

    func updateAmount(_ newAmount: AmountInput) {
        amount = newAmount
    }

    func save() {
        guard canSave, let value = amount.value else { return }
        limitStore.setLimit(value)
    }

    func removeLimit() {
        limitStore.setLimit(nil)
    }
}

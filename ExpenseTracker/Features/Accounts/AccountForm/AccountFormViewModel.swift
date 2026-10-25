//
//  AccountFormViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
final class AccountFormViewModel: ObservableObject {

    // MARK: - Input Data

    @Published var name: String = ""
    @Published var selectedIcon: String = Snapshot.defaultIcon
    @Published var selectedColor: String = Snapshot.defaultColor
    @Published var initialBalance: String = ""
    @Published var isDefault: Bool = false

    // MARK: - UI State

    @Published var showingSaveError = false

    // MARK: - Private Properties

    private(set) var editingAccount: Account?

    /// Состояние формы на момент открытия: по нему определяется, есть ли несохраненные правки
    private let initialSnapshot: Snapshot

    // MARK: - Init

    init(account: Account? = nil) {
        self.editingAccount = account
        self.initialSnapshot = Snapshot(account: account)

        name = initialSnapshot.name
        selectedIcon = initialSnapshot.icon
        selectedColor = initialSnapshot.color
        initialBalance = initialSnapshot.balance
        isDefault = initialSnapshot.isDefault
    }

    // MARK: - Computed Properties

    var isEditMode: Bool {
        editingAccount != nil
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isValid: Bool {
        !trimmedName.isEmpty
    }

    var navigationTitle: String {
        isEditMode ? AppString.editAccount : AppString.newAccount
    }

    var saveButtonTitle: String {
        guard isValid else { return AppString.enterName }

        return isEditMode ? AppString.saveChanges : AppString.createAccount
    }

    /// Закрытие формы с правками проходит через подтверждение
    var hasUnsavedChanges: Bool {
        currentSnapshot != initialSnapshot
    }

    private var currentSnapshot: Snapshot {
        Snapshot(
            name: name,
            icon: selectedIcon,
            color: selectedColor,
            balance: initialBalance,
            isDefault: isDefault
        )
    }

    private var balanceDecimal: Decimal? {
        Decimal(string: initialBalance.replacingOccurrences(of: ",", with: "."))
    }

    // MARK: - Actions

    func selectIcon(_ icon: String) {
        selectedIcon = icon
        provideFeedback(.light)
    }

    func selectColor(_ colorName: String) {
        selectedColor = colorName
        provideFeedback(.light)
    }

    /// Оставляет в поле баланса только то, что можно превратить в число:
    /// один минус в начале, цифры и один разделитель дробной части
    func sanitizeBalanceInput() {
        let isNegative = initialBalance.hasPrefix("-")
        var separatorUsed = false

        let digits = initialBalance.filter { character in
            if character.isNumber { return true }

            guard character == "." || character == "," else { return false }
            guard !separatorUsed else { return false }

            separatorUsed = true
            return true
        }

        let sanitized = (isNegative ? "-" : "") + digits

        if sanitized != initialBalance {
            initialBalance = sanitized
        }
    }

    /// - Returns: false — форма невалидна или запись не удалась; экран остается открытым
    func save(using repository: AccountRepository) -> Bool {
        guard isValid else { return false }

        let draft = AccountDraft(
            name: trimmedName,
            icon: selectedIcon,
            color: selectedColor,
            initialBalance: balanceDecimal ?? 0,
            isDefault: isDefault
        )

        do {
            if let account = editingAccount {
                try repository.update(account, with: draft)
            } else {
                try repository.add(draft)
            }
            return true
        } catch {
            showingSaveError = true
            return false
        }
    }

    func delete(using repository: AccountRepository) -> Bool {
        guard let account = editingAccount else { return false }

        do {
            try repository.delete(account)
            provideFeedback(.medium)
            return true
        } catch {
            showingSaveError = true
            return false
        }
    }

    // MARK: - Haptic Feedback

    private func provideFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

// MARK: - Snapshot

extension AccountFormViewModel {

    /// Слепок полей формы для сравнения «было / стало»
    struct Snapshot: Equatable {

        static let defaultIcon = "creditcard.fill"
        static let defaultColor = AppColorPalette.fallback.rawValue

        let name: String
        let icon: String
        let color: String
        let balance: String
        let isDefault: Bool

        init(account: Account?) {
            name = account?.name ?? ""
            icon = account?.icon ?? Self.defaultIcon
            color = account?.color ?? Self.defaultColor
            balance = Self.balanceText(for: account?.initialBalance)
            isDefault = account?.isDefault ?? false
        }

        init(name: String, icon: String, color: String, balance: String, isDefault: Bool) {
            self.name = name
            self.icon = icon
            self.color = color
            self.balance = balance
            self.isDefault = isDefault
        }

        /// Нулевой баланс показывается плейсхолдером, а не нулём в поле
        private static func balanceText(for balance: Decimal?) -> String {
            guard let balance, balance != 0 else { return "" }

            return "\(balance)"
        }
    }
}

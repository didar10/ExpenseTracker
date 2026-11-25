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
        isEditMode ? AppString.save : AppString.createAccount
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
        let normalized = initialBalance
            .replacingOccurrences(of: AppString.amountGroupingSeparator, with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "−", with: "-")
            .replacingOccurrences(of: ",", with: ".")
        return Decimal(string: normalized)
    }

    var selectedKind: AccountKind {
        get { AccountKind(icon: selectedIcon) }
        set {
            guard newValue != selectedKind else { return }
            selectedIcon = newValue.icon
        }
    }

    var deletionTitle: String { AppString.deleteNamedAccount(initialSnapshot.name) }

    var previewBalance: Decimal { balanceDecimal ?? 0 }

    /// Разряды форматируются при вводе; запятая и конечные нули сохраняются,
    /// чтобы «1 500,0» можно было дописать до «1 500,05».
    var balanceInput: String {
        get { initialBalance }
        set {
            initialBalance = newValue
            sanitizeBalanceInput()
        }
    }

    /// Форматирует только целую часть: дробные цифры еще могут дописываться.
    nonisolated private static func formattedBalanceInput(_ source: String) -> String {
        guard !source.isEmpty, source != "-" else { return source }
        let normalized = source.replacingOccurrences(of: ",", with: ".")
        let parts = normalized.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        let integer = String(parts[0])
        let negativeZero = integer.hasPrefix("-") && (Decimal(string: integer) ?? 0) == 0
        let grouped = (negativeZero ? "−" : "") + MoneyFormat.number(Decimal(string: integer) ?? 0)
        return parts.count > 1 ? grouped + "," + parts[1] : grouped
    }

    // MARK: - Actions

    /// Оставляет в поле баланса только то, что можно превратить в число:
    /// один минус в начале, цифры и один разделитель дробной части
    func sanitizeBalanceInput() {
        let source = initialBalance.replacingOccurrences(of: "−", with: "-")
        let isNegative = source.hasPrefix("-")
        var separatorUsed = false

        let digits = source.filter { character in
            if character.isNumber { return true }

            guard character == "." || character == "," else { return false }
            guard !separatorUsed else { return false }

            separatorUsed = true
            return true
        }

        let sanitized = Self.formattedBalanceInput((isNegative ? "-" : "") + digits)

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

        static let defaultIcon = AccountKind.card.icon
        static let defaultColor = DS.AccountColor.yellow.rawValue

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
            isDefault = account?.isDefault ?? true
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

            return AccountFormViewModel.formattedBalanceInput("\(balance)")
        }
    }
}

//
//  AddTransactionViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import Foundation
import SwiftData
import UIKit

@MainActor
final class AddTransactionViewModel: ObservableObject {

    // MARK: - Types

    /// Ограничения ввода суммы: длиннее уже не помещается в поле и не имеет смысла для денег
    private enum AmountLimit {
        static let integerDigits = 12
        static let fractionDigits = 2
        static let groupSize = 3
    }

    /// Снимок полей формы для сравнения «есть ли несохраненные изменения»
    private struct InputSnapshot: Equatable {
        let amount: String
        let categoryID: PersistentIdentifier?
        let accountID: PersistentIdentifier?
        let note: String
        let date: Date
        let type: TransactionType
    }

    // MARK: - Input Data

    @Published var amount: String = ""
    @Published var selectedCategory: Category?
    @Published var selectedAccount: Account?
    @Published var note: String = ""
    @Published var date: Date = .now
    @Published var type: TransactionType = .expense

    // MARK: - UI State

    @Published var showSuccessAnimation = false
    @Published var showAllCategories = false
    /// Транзакция уже записана в контекст: защищает от повторного сохранения
    @Published private(set) var isSaved = false

    private(set) var editingTransaction: Transaction?

    private let accountSelection: AccountSelectionStore
    private var initialSnapshot = InputSnapshot(
        amount: "",
        categoryID: nil,
        accountID: nil,
        note: "",
        date: .now,
        type: .expense
    )

    // MARK: - Init

    init(transaction: Transaction? = nil, accountSelection: AccountSelectionStore) {
        self.editingTransaction = transaction
        self.accountSelection = accountSelection

        defer { initialSnapshot = currentSnapshot }

        guard let transaction else {
            // Новая операция создается на счете, выбранном на других экранах
            selectedAccount = accountSelection.selectedAccount
            return
        }

        amount = transaction.amount.description
        selectedCategory = transaction.category
        selectedAccount = transaction.account
        note = transaction.note ?? ""
        date = transaction.date
        type = transaction.type
    }

    // MARK: - Computed Properties

    var isEditing: Bool {
        editingTransaction != nil
    }

    var screenTitle: String {
        isEditing ? AppString.editTransaction : AppString.newTransaction
    }

    var saveButtonTitle: String {
        isEditing ? AppString.saveChanges : AppString.save
    }

    var isSaveEnabled: Bool {
        !isSaved && hasPositiveAmount && selectedAccount != nil
    }

    /// Чего не хватает для сохранения — показывается под кнопкой вместо молчаливой блокировки
    var validationHint: String? {
        guard !isSaved else { return nil }

        if selectedAccount == nil { return AppString.chooseAccount }
        if !hasPositiveAmount { return AppString.enterAmount }

        return nil
    }

    /// Пользователь что-то ввел и уйти по свайпу/крестику без подтверждения нельзя
    var hasUnsavedChanges: Bool {
        !isSaved && currentSnapshot != initialSnapshot
    }

    /// Сумма для предпросмотра баланса счёта: после сохранения транзакция
    /// уже учтена в `currentBalance`, поэтому вычитать её повторно нельзя
    var pendingAmount: String {
        isSaved ? "" : amount
    }

    /// Баланс счета после этой операции: показывается в плитке счета во время ввода
    var predictedBalance: Decimal? {
        guard let selectedAccount, !isSaved, let value = amountDecimal, value > 0 else { return nil }

        return type == .income
            ? selectedAccount.currentBalance + value
            : selectedAccount.currentBalance - value
    }

    /// Сумма с разделителями разрядов для отображения: 1350000 → 1 350 000
    var amountDisplay: String {
        guard !amount.isEmpty else { return "0" }

        let parts = amount.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        let groupedInteger = Self.groupedDigits(String(parts[0]))

        guard parts.count > 1 else { return groupedInteger }

        return groupedInteger + AppString.amountDecimalSeparator + parts[1]
    }

    /// Введена ли сумма — влияет на цвет «0» на экране: набранный ноль не плейсхолдер
    var hasAmountInput: Bool {
        !amount.isEmpty
    }

    private var hasPositiveAmount: Bool {
        guard let value = amountDecimal else { return false }

        return value > 0
    }

    private var amountDecimal: Decimal? {
        Decimal(string: amount.replacingOccurrences(of: ",", with: "."))
    }

    private var currentSnapshot: InputSnapshot {
        InputSnapshot(
            amount: amount,
            categoryID: selectedCategory?.persistentModelID,
            accountID: selectedAccount?.persistentModelID,
            note: note,
            date: date,
            type: type
        )
    }

    // MARK: - Actions

    func selectCategory(_ category: Category) {
        selectedCategory = category
        provideFeedback(.medium)
    }
    
    func toggleShowAllCategories() {
        showAllCategories.toggle()
        provideFeedback(.light)
    }
    
    func changeType(to type: TransactionType) {
        self.type = type
        provideFeedback(.medium)
    }

    /// Категория другого типа не должна оставаться выбранной после смены «Расход/Доход»
    func resetCategoryIfTypeMismatched() {
        guard selectedCategory?.type != type else { return }

        selectedCategory = nil
    }

    /// Счет по умолчанию подставляется один раз, когда экран открыли без общего выбора
    func applyDefaultAccountIfNeeded(from accounts: [Account]) {
        guard selectedAccount == nil else { return }

        selectedAccount = accounts.first { $0.isDefault } ?? accounts.first
        initialSnapshot = currentSnapshot
    }

    // MARK: - Save

    func save(using context: ModelContext) -> Bool {
        guard !isSaved, let value = amountDecimal, value > 0 else { return false }
        
        provideFeedback(.medium)

        if let transaction = editingTransaction {
            transaction.amount = value
            transaction.category = selectedCategory
            transaction.account = selectedAccount
            transaction.note = note.isEmpty ? nil : note
            transaction.date = date
            transaction.type = type
        } else {
            let newTransaction = Transaction(
                amount: value,
                date: date,
                note: note.isEmpty ? nil : note,
                type: type,
                category: selectedCategory,
                account: selectedAccount
            )
            context.insert(newTransaction)
        }

        isSaved = true
        syncSharedAccountSelection()

        return true
    }

    /// Общий выбор счета переходит на счет сохраненной операции.
    /// Режим «Все счета» не трогаем — иначе другие экраны неожиданно окажутся отфильтрованы
    private func syncSharedAccountSelection() {
        guard accountSelection.selectedAccount != nil, let selectedAccount else { return }

        accountSelection.selectedAccount = selectedAccount
    }
    
    func showSuccessAndDismiss(onDismiss: @escaping () -> Void) {
        showSuccessAnimation = true
        
        Task {
            try? await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
            onDismiss()
        }
    }

    // MARK: - Keypad Logic

    func handleKeyTap(_ key: NumericKeypadView.Key) {
        let isAccepted: Bool

        switch key {
        case .number(let value):
            isAccepted = appendNumber(value)
        case .decimal:
            isAccepted = appendDecimal()
        case .delete:
            isAccepted = deleteLast()
        }

        // Отклоненный ввод (предел длины, пустое поле) не должен ощущаться как принятый
        guard isAccepted else { return }

        provideFeedback(.light)
    }

    /// Долгое нажатие на удаление стирает всю сумму
    func clearAmount() {
        guard !amount.isEmpty else { return }

        amount = ""
        provideFeedback(.medium)
    }

    @discardableResult
    private func appendNumber(_ value: String) -> Bool {
        guard canAppendDigit else { return false }

        if amount == "0" {
            amount = value
        } else {
            amount.append(value)
        }

        return true
    }

    @discardableResult
    private func appendDecimal() -> Bool {
        guard !amount.contains(AppString.amountDecimalSeparator) else { return false }

        amount = amount.isEmpty ? "0." : amount + AppString.amountDecimalSeparator

        return true
    }

    @discardableResult
    private func deleteLast() -> Bool {
        guard !amount.isEmpty else { return false }

        amount.removeLast()

        return true
    }

    /// Целая часть ограничена длиной поля, дробная — копейками
    private var canAppendDigit: Bool {
        let parts = amount.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)

        guard parts.count > 1 else {
            return amount.count < AmountLimit.integerDigits
        }

        return parts[1].count < AmountLimit.fractionDigits
    }
    
    // MARK: - Amount Formatting

    /// Разбивает целую часть суммы на группы по три цифры справа налево
    private static func groupedDigits(_ digits: String) -> String {
        var reversedGrouped = ""

        for (offset, character) in digits.reversed().enumerated() {
            if offset > 0, offset % AmountLimit.groupSize == 0 {
                reversedGrouped.append(AppString.amountGroupingSeparator)
            }
            reversedGrouped.append(character)
        }

        return String(reversedGrouped.reversed())
    }

    // MARK: - Haptic Feedback

    private func provideFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

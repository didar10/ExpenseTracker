//
//  AddTransactionViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import Foundation
import SwiftData

@MainActor
final class AddTransactionViewModel: ObservableObject {

    // MARK: - Types

    /// Состояние кнопки сохранения под клавиатурой
    enum SaveButtonState: Equatable {
        /// Суммы нет — «Введите сумму», кнопка неактивна
        case enterAmount
        /// Выражение с ошибкой — «Проверьте сумму», кнопка неактивна
        case checkAmount
        /// Счета нет — «Выберите счет», кнопка неактивна
        case chooseAccount
        /// Есть выражение — «= Сохранить 2 000 ₸»
        case saveResult(String)
        /// «Сохранить расход / доход», в редактировании — «Сохранить изменения»
        case save(String)

        var title: String {
            switch self {
            case .enterAmount: return AppString.enterAmount
            case .checkAmount: return AppString.checkAmount
            case .chooseAccount: return AppString.chooseAccount
            case .saveResult(let amount): return AppString.saveAmount(amount)
            case .save(let title): return title
            }
        }

        var isEnabled: Bool {
            switch self {
            case .saveResult, .save: return true
            case .enterAmount, .checkAmount, .chooseAccount: return false
            }
        }

        /// Перед суммой выражения кнопка показывает «=»
        var showsEqualsSign: Bool {
            if case .saveResult = self { return true }
            return false
        }
    }

    /// Снимок полей формы для сравнения «есть ли несохраненные изменения»
    private struct InputSnapshot: Equatable {
        let calculator: CalculatorEngine
        let categoryID: PersistentIdentifier?
        let accountID: PersistentIdentifier?
        let note: String
        let date: Date
        let type: TransactionType
    }

    // MARK: - Input Data

    @Published private(set) var calculator = CalculatorEngine()
    @Published var selectedCategory: Category?
    @Published var selectedAccount: Account?
    @Published var note: String = ""
    @Published var date: Date = .now
    @Published var type: TransactionType = .expense

    // MARK: - UI State

    /// Транзакция уже записана в контекст: защищает от повторного сохранения
    @Published private(set) var isSaved = false
    /// Запись на диск не удалась: экран остается открытым с введенными данными
    @Published var showingSaveError = false

    private(set) var editingTransaction: Transaction?

    private let accountSelection: AccountSelectionStore
    private var initialSnapshot: InputSnapshot?

    // MARK: - Init

    /// - Parameters:
    ///   - transaction: операция для редактирования
    ///   - template: «Дублировать» — новая операция с суммой, категорией, счетом и заметкой
    ///     шаблона и сегодняшней датой. Игнорируется при редактировании
    init(
        transaction: Transaction? = nil,
        template: Transaction? = nil,
        accountSelection: AccountSelectionStore
    ) {
        self.editingTransaction = transaction
        self.accountSelection = accountSelection

        defer { initialSnapshot = currentSnapshot }

        guard let transaction else {
            // Новая операция создается на счете, выбранном на других экранах
            selectedAccount = accountSelection.selectedAccount

            if let template {
                applyTemplate(template)
            }
            return
        }

        calculator = CalculatorEngine(amount: transaction.amount)
        selectedCategory = transaction.category
        selectedAccount = transaction.account
        note = transaction.note ?? ""
        date = transaction.date
        type = transaction.type ?? .expense
    }

    // MARK: - Computed Properties

    var isEditing: Bool {
        editingTransaction != nil
    }

    var screenTitle: String {
        isEditing ? AppString.editTransaction : AppString.newTransaction
    }

    /// Строка над суммой — только когда в выражении есть оператор: «1 200 + 800»
    var expressionText: String? {
        calculator.hasOperator ? calculator.expressionText : nil
    }

    /// Крупная сумма: набранное число, итог выражения или «—» при делении на ноль
    var amountText: String {
        guard calculator.hasOperator else {
            let typed = calculator.expressionText
            return typed.isEmpty ? Constants.zero : typed
        }

        if calculator.error == .divisionByZero {
            return Constants.dash
        }
        return calculator.result.map(MoneyFormat.number) ?? Constants.zero
    }

    /// Ноль — еще не введенная сумма: показывается серым
    var isAmountPlaceholder: Bool {
        calculator.error == nil && (calculator.result ?? .zero) == .zero
    }

    var errorMessage: String? {
        calculator.error?.message
    }

    var saveButtonState: SaveButtonState {
        if calculator.error != nil { return .checkAmount }
        guard let amount, !isSaved else { return .enterAmount }
        guard selectedAccount != nil else { return .chooseAccount }

        if calculator.hasOperator {
            return .saveResult(MoneyFormat.money(amount))
        }
        if isEditing {
            return .save(AppString.saveChanges)
        }
        return .save(type == .income ? AppString.saveIncome : AppString.saveExpense)
    }

    var isSaveEnabled: Bool {
        saveButtonState.isEnabled
    }

    /// Пользователь что-то ввел и уйти по свайпу/крестику без подтверждения нельзя
    var hasUnsavedChanges: Bool {
        !isSaved && currentSnapshot != initialSnapshot
    }

    /// Сумма к сохранению: итог выражения больше нуля и без ошибок
    private var amount: Decimal? {
        calculator.isValid ? calculator.result : nil
    }

    private var currentSnapshot: InputSnapshot {
        InputSnapshot(
            calculator: calculator,
            categoryID: selectedCategory?.persistentModelID,
            accountID: selectedAccount?.persistentModelID,
            note: note,
            date: date,
            type: type
        )
    }

    // MARK: - Actions

    /// Копия операции на сегодня. Архивный счет не подставляется — на нем нельзя сохранить
    private func applyTemplate(_ template: Transaction) {
        calculator = CalculatorEngine(amount: template.amount)
        type = template.type ?? .expense
        selectedCategory = template.category
        note = template.note ?? ""
        date = .now

        if let account = template.account, account.isAvailable {
            selectedAccount = account
        }
    }

    func input(_ key: CalculatorKey) {
        calculator.input(key)
    }

    /// Категория другого типа не должна оставаться выбранной после смены «Расход/Доход»
    func resetCategoryIfTypeMismatched() {
        guard let selectedCategory, selectedCategory.type != type else { return }

        self.selectedCategory = nil
    }

    /// Счет по умолчанию подставляется один раз, когда экран открыли без общего выбора
    func applyDefaultAccountIfNeeded(from accounts: [Account]) {
        guard selectedAccount == nil else { return }

        selectedAccount = accounts.first { $0.isDefault } ?? accounts.first
        initialSnapshot = currentSnapshot
    }

    // MARK: - Save

    func save(using repository: TransactionRepository) -> Bool {
        guard editingTransaction?.kind != .transfer, isSaveEnabled, let amount else { return false }

        let draft = TransactionDraft(
            amount: amount,
            date: date,
            note: note.isEmpty ? nil : note,
            type: type,
            category: selectedCategory,
            account: selectedAccount
        )

        do {
            if let transaction = editingTransaction {
                try repository.update(transaction, with: draft)
            } else {
                try repository.add(draft)
            }
        } catch {
            // Репозиторий вернул операцию к сохраненному виду,
            // а введенные значения остались в полях — можно повторить
            showingSaveError = true
            return false
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

    // MARK: - Category Spending

    /// Траты (или доходы) каждой категории за месяц `now` — для порядка ленты и подписей.
    /// Ключ — `Category.id`
    static func monthlySpending(
        of categories: [Category],
        calendar: Calendar = .current,
        now: Date = .now
    ) -> [UUID: Decimal] {
        guard let month = calendar.dateInterval(of: .month, for: now) else { return [:] }

        var result: [UUID: Decimal] = [:]
        for category in categories {
            result[category.id] = category.transactions
                .filter { $0.type == category.type && month.contains($0.date) }
                .reduce(Decimal.zero) { $0 + $1.amount }
        }
        return result
    }
}

// MARK: - Constants

private enum Constants {
    static let zero = "0"
    static let dash = "—"
}

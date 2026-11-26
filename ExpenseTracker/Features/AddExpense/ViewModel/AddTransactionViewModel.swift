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
        /// Перевод без счета списания — «Выберите счёт списания»
        case chooseSourceAccount
        /// Перевод без счета зачисления — «Выберите счёт зачисления»
        case chooseTargetAccount
        /// Новый перевод — «⇄ Перевести 50 000 ₸»
        case transfer(String)
        /// Есть выражение — «= Сохранить 2 000 ₸»
        case saveResult(String)
        /// «Сохранить расход / доход», в редактировании — «Сохранить изменения»
        case save(String)

        var title: String {
            switch self {
            case .enterAmount: return AppString.enterAmount
            case .checkAmount: return AppString.checkAmount
            case .chooseAccount: return AppString.chooseAccount
            case .chooseSourceAccount: return AppString.transferChooseSource
            case .chooseTargetAccount: return AppString.transferChooseTarget
            case .transfer(let amount): return AppString.transferAmount(amount)
            case .saveResult(let amount): return AppString.saveAmount(amount)
            case .save(let title): return title
            }
        }

        var isEnabled: Bool {
            switch self {
            case .saveResult, .save, .transfer: return true
            case .enterAmount, .checkAmount, .chooseAccount, .chooseSourceAccount, .chooseTargetAccount: return false
            }
        }

        /// Перед суммой выражения кнопка показывает «=»
        var showsEqualsSign: Bool {
            if case .saveResult = self { return true }
            return false
        }

        /// Перед суммой перевода кнопка показывает «⇄»
        var showsTransferSign: Bool {
            if case .transfer = self { return true }
            return false
        }
    }

    /// Строка карточки «Откуда / Куда»: какой счет выбирается
    enum TransferSide: Identifiable {
        case from
        case to

        var id: Self { self }
    }

    /// Баланс счета в карточке перевода: «78 300 ₸ → 28 300 ₸»
    struct TransferBalance: Equatable {
        let current: Decimal
        /// nil — суммы еще нет, показывается только текущий баланс
        let after: Decimal?

        var isNegativeAfter: Bool {
            (after ?? .zero) < .zero
        }
    }

    /// Снимок полей формы для сравнения «есть ли несохраненные изменения»
    private struct InputSnapshot: Equatable {
        let calculator: CalculatorEngine
        let categoryID: PersistentIdentifier?
        let accountID: PersistentIdentifier?
        let toAccountID: PersistentIdentifier?
        let note: String
        let date: Date
        let kind: TransactionKind
    }

    // MARK: - Input Data

    @Published private(set) var calculator = CalculatorEngine()
    /// Что изменило последнее нажатие клавиши — для анимации суммы
    @Published private(set) var keystrokes = AmountKeystrokes()
    @Published var selectedCategory: Category?
    /// Счет расхода или дохода; в переводе — счет списания «Откуда»
    @Published var selectedAccount: Account?
    /// Счет зачисления «Куда» — только у перевода
    @Published private(set) var toAccount: Account?
    @Published var note: String = ""
    @Published var date: Date = .now
    @Published var kind: TransactionKind = .expense

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
        note = transaction.note ?? ""
        date = transaction.date
        kind = transaction.kind

        if transaction.kind == .transfer {
            selectedAccount = transaction.fromAccount
            toAccount = transaction.toAccount
        } else {
            selectedAccount = transaction.account
        }
    }

    // MARK: - Computed Properties

    var isEditing: Bool {
        editingTransaction != nil
    }

    var isTransfer: Bool {
        kind == .transfer
    }

    /// Тип категорий для ленты: в переводе категорий нет, остается последний выбранный тип
    var type: TransactionType {
        get { kind.entryType ?? .expense }
        set { kind = TransactionKind(newValue) }
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

        if isTransfer {
            return transferSaveButtonState(amount: amount)
        }

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

    // MARK: - Transfer

    var fromBalance: TransferBalance? {
        transferBalance(of: availableFromAccount, sign: -1)
    }

    var toBalance: TransferBalance? {
        transferBalance(of: availableToAccount, sign: 1)
    }

    /// Баланс списания уйдет в минус. Сохранение не блокируется — только предупреждение
    var isOverdrawn: Bool {
        isTransfer && fromBalance?.isNegativeAfter == true && amount != nil
    }

    /// «На счёте «Наличные» 12 000 ₸ — после перевода баланс уйдёт в минус»
    var overdraftWarning: String? {
        guard isOverdrawn, let account = availableFromAccount, let balance = fromBalance else { return nil }

        return AppString.transferOverdraftWarning(account: account.name, balance: MoneyFormat.money(balance.current))
    }

    var availableFromAccount: Account? {
        selectedAccount.flatMap { $0.isAvailable ? $0 : nil }
    }

    var availableToAccount: Account? {
        toAccount.flatMap { $0.isAvailable ? $0 : nil }
    }

    /// Счет другой строки: на листе выбора он недоступен
    func counterpartAccount(for side: TransferSide) -> Account? {
        side == .from ? availableToAccount : availableFromAccount
    }

    private func transferSaveButtonState(amount: Decimal) -> SaveButtonState {
        guard availableFromAccount != nil else { return .chooseSourceAccount }
        guard let toAccount = availableToAccount, !isSameAccount(toAccount, selectedAccount) else {
            return .chooseTargetAccount
        }

        if isEditing {
            return calculator.hasOperator ? .saveResult(MoneyFormat.money(amount)) : .save(AppString.saveChanges)
        }
        return .transfer(MoneyFormat.money(amount))
    }

    /// Баланс без редактируемой операции: иначе перевод учелся бы дважды
    private func transferBalance(of account: Account?, sign: Decimal) -> TransferBalance? {
        guard let account else { return nil }

        let current = account.currentBalance - editingEffect(on: account)
        return TransferBalance(current: current, after: amount.map { current + sign * $0 })
    }

    /// Насколько сохраненная версия редактируемой операции изменила баланс счета
    private func editingEffect(on account: Account) -> Decimal {
        guard let transaction = editingTransaction, !transaction.isDeleted else { return .zero }

        switch transaction.kind {
        case .transfer:
            let incoming = isSameAccount(transaction.toAccount, account) ? transaction.amount : .zero
            let outgoing = isSameAccount(transaction.fromAccount, account) ? transaction.amount : .zero
            return incoming - outgoing
        case .expense, .income:
            return isSameAccount(transaction.account, account) ? transaction.netIncome : .zero
        }
    }

    private func isSameAccount(_ lhs: Account?, _ rhs: Account?) -> Bool {
        guard let lhs, let rhs else { return false }
        return lhs.persistentModelID == rhs.persistentModelID
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
            toAccountID: isTransfer ? toAccount?.persistentModelID : nil,
            note: note,
            date: date,
            kind: kind
        )
    }

    // MARK: - Actions

    /// Копия операции на сегодня. Архивный счет не подставляется — на нем нельзя сохранить
    private func applyTemplate(_ template: Transaction) {
        calculator = CalculatorEngine(amount: template.amount)
        kind = template.kind
        selectedCategory = template.category
        note = template.note ?? ""
        date = .now

        let source = template.kind == .transfer ? template.fromAccount : template.account
        if let source, source.isAvailable {
            selectedAccount = source
        }
        if template.kind == .transfer, let target = template.toAccount, target.isAvailable {
            toAccount = target
        }
    }

    func input(_ key: CalculatorKey) {
        let previous = calculator
        calculator.input(key)

        guard calculator != previous else { return }
        keystrokes.record(key, hasOperator: calculator.hasOperator)
    }

    /// Счет расхода/дохода или «Откуда» перевода. Совпавший счет «Куда» сбрасывается:
    /// перевод на тот же счет невозможен
    func selectAccount(_ account: Account) {
        selectedAccount = account
        if isSameAccount(toAccount, account) {
            toAccount = nil
        }
    }

    func selectAccount(_ account: Account, for side: TransferSide) {
        switch side {
        case .from:
            selectAccount(account)
        case .to:
            toAccount = account
            if isSameAccount(selectedAccount, account) {
                selectedAccount = nil
            }
        }
    }

    /// ⇄ — счета меняются местами, пустая строка тоже переезжает
    func swapTransferAccounts() {
        (selectedAccount, toAccount) = (toAccount, selectedAccount)
    }

    /// Категория другого типа не должна оставаться выбранной после смены «Расход/Доход»
    func resetCategoryIfTypeMismatched() {
        guard !isTransfer, let selectedCategory, selectedCategory.type != type else { return }

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
        guard isSaveEnabled, let amount, let draft = makeDraft(amount: amount) else { return false }

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

    private func makeDraft(amount: Decimal) -> TransactionDraft? {
        let note = note.isEmpty ? nil : note

        guard isTransfer else {
            return TransactionDraft(
                amount: amount,
                date: date,
                note: note,
                type: type,
                category: selectedCategory,
                account: selectedAccount
            )
        }

        guard let fromAccount = availableFromAccount, let toAccount = availableToAccount else { return nil }
        return TransactionDraft(amount: amount, date: date, note: note, fromAccount: fromAccount, toAccount: toAccount)
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

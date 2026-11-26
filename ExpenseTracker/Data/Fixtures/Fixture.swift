//
//  Fixture.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

#if DEBUG

import Foundation
import SwiftData

/// Тестовые данные для `#Preview`, снапшотов и отладочной загрузки в Настройках.
/// Реальная база в превью и снапшотах не участвует
enum Fixture: CaseIterable {

    /// Счета Freedom, Kaspi Gold и Наличные, операции за текущий месяц, лимит и бюджеты категорий
    case sample
    /// Пустая база: ни счетов, ни категорий, ни операций; лимит не задан
    case empty

    // MARK: - Computed Properties

    /// Общий лимит трат на месяц, который фикстура выставляет в `MonthlyLimitStore`
    var monthlyLimit: Decimal? {
        switch self {
        case .sample: return SampleData.monthlyLimit
        case .empty: return nil
        }
    }

    // MARK: - Methods

    /// Наполняет пустой контекст и сохраняет его.
    /// - Parameter now: «сегодня» фикстуры; операции попадают в месяц этой даты и не позже нее
    @MainActor
    func populate(_ context: ModelContext, now: Date = .now) throws {
        switch self {
        case .sample: try SampleData.insert(into: context, now: now)
        case .empty: break
        }

        try context.saveOrRollback()
    }
}

// MARK: - Sample Data

private enum SampleData {

    // MARK: - Types

    enum AccountKey: CaseIterable {
        case freedom, kaspi, cash
    }

    enum CategoryKey: CaseIterable {
        case food, transport, shopping, home, entertainment
        case salary, sideJob, gift, investments
    }

    struct AccountSpec {
        let name: String
        let icon: String
        let color: String
        let initialBalance: Decimal
        var isDefault = false
    }

    struct CategorySpec {
        let name: String
        let icon: String
        let colorHex: String
        var type: TransactionType = .expense
    }

    struct Operation {
        let day: Int
        let hour: Int
        let amount: Decimal
        let category: CategoryKey
        let account: AccountKey
        let note: String?
    }

    // MARK: - Data

    static let monthlyLimit: Decimal = 400_000

    static let accounts: [AccountKey: AccountSpec] = [
        .freedom: AccountSpec(name: "Freedom", icon: "creditcard.fill", color: "green", initialBalance: 250_000),
        .kaspi: AccountSpec(name: "Kaspi Gold", icon: "creditcard.fill", color: "red", initialBalance: 120_000, isDefault: true),
        .cash: AccountSpec(name: "Наличные", icon: "banknote.fill", color: "orange", initialBalance: 35_000)
    ]

    static let categories: [CategoryKey: CategorySpec] = [
        .food: CategorySpec(name: "Еда", icon: "fork.knife", colorHex: "#34C759"),
        .transport: CategorySpec(name: "Транспорт", icon: "car.fill", colorHex: "#007AFF"),
        .shopping: CategorySpec(name: "Покупки", icon: "cart.fill", colorHex: "#FF9500"),
        .home: CategorySpec(name: "Дом", icon: "house.fill", colorHex: "#AF52DE"),
        .entertainment: CategorySpec(name: "Развлечения", icon: "gamecontroller.fill", colorHex: "#FF2D55"),
        .salary: CategorySpec(name: "Зарплата", icon: "banknote.fill", colorHex: "#34C759", type: .income),
        .sideJob: CategorySpec(name: "Подработка", icon: "briefcase.fill", colorHex: "#007AFF", type: .income),
        .gift: CategorySpec(name: "Подарок", icon: "gift.fill", colorHex: "#FF2D55", type: .income),
        .investments: CategorySpec(name: "Инвестиции", icon: "chart.line.uptrend.xyaxis", colorHex: "#5856D6", type: .income)
    ]

    /// Бюджеты: «Развлечения» превышен, «Еда» близко к лимиту, остальные с запасом
    static let budgets: [(CategoryKey, Decimal)] = [
        (.food, 60_000),
        (.transport, 40_000),
        (.shopping, 50_000),
        (.entertainment, 15_000)
    ]

    static let operations: [Operation] = [
        Operation(day: 1, hour: 10, amount: 650_000, category: .salary, account: .freedom, note: nil),
        Operation(day: 1, hour: 19, amount: 18_450, category: .food, account: .kaspi, note: "Magnum"),
        Operation(day: 2, hour: 8, amount: 2_300, category: .transport, account: .kaspi, note: "Яндекс Go"),
        Operation(day: 3, hour: 12, amount: 38_700, category: .home, account: .freedom, note: "Коммунальные услуги"),
        Operation(day: 4, hour: 9, amount: 1_900, category: .food, account: .cash, note: "Кофе"),
        Operation(day: 5, hour: 18, amount: 15_000, category: .transport, account: .freedom, note: "Бензин"),
        Operation(day: 6, hour: 21, amount: 12_500, category: .entertainment, account: .kaspi, note: "Steam"),
        Operation(day: 7, hour: 14, amount: 24_990, category: .shopping, account: .kaspi, note: "Wildberries"),
        Operation(day: 8, hour: 11, amount: 85_000, category: .sideJob, account: .kaspi, note: "Фриланс"),
        Operation(day: 9, hour: 20, amount: 6_200, category: .food, account: .cash, note: "Small"),
        Operation(day: 10, hour: 19, amount: 6_000, category: .entertainment, account: .cash, note: "Кино"),
        Operation(day: 11, hour: 13, amount: 9_990, category: .home, account: .freedom, note: "Интернет"),
        Operation(day: 12, hour: 18, amount: 22_300, category: .food, account: .kaspi, note: "Galmart"),
        Operation(day: 13, hour: 10, amount: 20_000, category: .gift, account: .cash, note: "От родителей")
    ]

    static let transfers: [(day: Int, hour: Int, amount: Decimal, from: AccountKey, to: AccountKey)] = [
        (5, 13, 50_000, .kaspi, .cash),
        (8, 14, 75_000, .freedom, .kaspi),
        (12, 11, 10_000, .cash, .freedom)
    ]

    // MARK: - Methods

    static func insert(into context: ModelContext, now: Date) throws {
        // Модели создаются заново на каждый вызов: SwiftData-модель живет в одном контексте
        let accounts = self.accounts.mapValues {
            Account(name: $0.name, icon: $0.icon, color: $0.color, initialBalance: $0.initialBalance, isDefault: $0.isDefault)
        }
        let categories = self.categories.mapValues {
            Category(name: $0.name, icon: $0.icon, colorHex: $0.colorHex, type: $0.type)
        }

        // Порядок вставки и дата создания фиксированы: от них зависит порядок счетов на экранах,
        // а словарь перебирается в случайном порядке
        for (index, key) in AccountKey.allCases.enumerated() {
            guard let account = accounts[key] else { continue }
            account.createdAt = now.addingTimeInterval(TimeInterval(index - AccountKey.allCases.count))
            context.insert(account)
        }
        CategoryKey.allCases.compactMap { categories[$0] }.forEach(context.insert)

        for (key, limit) in budgets {
            guard let category = categories[key] else { continue }
            context.insert(BudgetPlan(category: category, monthlyLimit: limit))
        }

        for operation in operations {
            guard let category = categories[operation.category] else { continue }

            context.insert(
                Transaction(
                    amount: operation.amount,
                    date: date(day: operation.day, hour: operation.hour, now: now),
                    note: operation.note,
                    type: category.type,
                    category: category,
                    account: accounts[operation.account]
                )
            )
        }

        for transfer in transfers {
            guard let from = accounts[transfer.from], let to = accounts[transfer.to] else { continue }
            let draft = TransactionDraft(
                amount: transfer.amount,
                date: date(day: transfer.day, hour: transfer.hour, now: now),
                fromAccount: from,
                toAccount: to
            )
            context.insert(try Transaction(validating: draft))
        }
    }

    // MARK: - Private Methods

    /// День месяца `now`; если этот день еще не наступил, операция переносится
    /// на прошедшие дни по кругу, чтобы в начале месяца все данные оставались в прошлом
    private static func date(day: Int, hour: Int, now: Date) -> Date {
        let calendar = Calendar.current
        let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let elapsedDays = calendar.dateComponents([.day], from: monthStart, to: now).day ?? 0
        let dayOffset = (day - 1) % (elapsedDays + 1)

        let dayStart = calendar.date(byAdding: .day, value: dayOffset, to: monthStart) ?? monthStart
        let date = calendar.date(byAdding: .hour, value: hour, to: dayStart) ?? dayStart

        return min(date, now)
    }
}

#endif

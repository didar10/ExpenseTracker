import Foundation
import SwiftData

/// Фильтр, с которым открыли лист. Данные операций под ним остаются живыми.
struct CategoryTransactionsScope {
    let period: StatisticsPeriod
    let interval: DateInterval
    let title: String
    let type: TransactionType
    var accountID: PersistentIdentifier?

    func transactions(from transactions: [Transaction], categoryID: UUID) -> [Transaction] {
        transactions.filter { transaction in
            guard !transaction.isDeleted,
                  transaction.type == type,
                  transaction.date >= interval.start,
                  transaction.date < interval.end,
                  let category = transaction.category,
                  !category.isDeleted, category.id == categoryID else { return false }
            return accountID == nil || transaction.account?.persistentModelID == accountID
        }
    }

    func budget(in plans: [BudgetPlan]) -> Decimal? {
        guard type == .expense else { return nil }
        let matchingPeriod: BudgetPeriod
        switch period {
        case .week: matchingPeriod = .week
        case .month: matchingPeriod = .month
        case .year: matchingPeriod = .year
        case .day, .allTime: return nil
        }
        return plans.filter { !$0.isDeleted && $0.isActive && $0.period == matchingPeriod }
            .max(by: { $0.createdAt < $1.createdAt })?.monthlyLimit
    }

    var totalTitle: String {
        if period == .day && title == AppString.today { return AppString.categoryTotalToday }
        if period == .day && title == AppString.yesterday { return AppString.categoryTotalYesterday }
        return AppString.categoryTotal(period == .allTime ? AppString.periodAllTimeMenu : title)
    }

    var emptyMessage: String {
        switch period {
        case .month: AppString.categoryNoMonthlyTransactions
        case .allTime: AppString.noTransactions
        default: AppString.noTransactionsInPeriod(title)
        }
    }

    static func budgetPercent(total: Decimal, limit: Decimal) -> Int? {
        guard limit > 0 else { return nil }
        var source = total * 100 / limit
        var rounded = Decimal.zero
        NSDecimalRound(&rounded, &source, 0, .down)
        return NSDecimalNumber(decimal: rounded).intValue
    }
}

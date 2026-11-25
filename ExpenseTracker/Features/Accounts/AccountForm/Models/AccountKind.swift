import Foundation

/// Тип хранится существующей иконкой счета; произвольные старые иконки не меняются при открытии формы.
enum AccountKind: String, CaseIterable {
    case card, cash, deposit

    var title: String {
        switch self {
        case .card: return AppString.accountKindCard
        case .cash: return AppString.accountKindCash
        case .deposit: return AppString.accountKindDeposit
        }
    }

    var icon: String {
        switch self {
        case .card: return "creditcard"
        case .cash: return "banknote"
        case .deposit: return "building.columns"
        }
    }

    init(icon: String) {
        switch icon {
        case "banknote", "banknote.fill", "tengesign.circle.fill", "dollarsign.circle.fill": self = .cash
        case "building.columns", "building.columns.fill", "chart.line.uptrend.xyaxis", "lock.fill": self = .deposit
        default: self = .card
        }
    }
}

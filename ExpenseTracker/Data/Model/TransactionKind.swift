enum TransactionKind: String, Codable {
    case expense
    case income
    case transfer

    init(_ type: TransactionType) {
        switch type {
        case .expense: self = .expense
        case .income: self = .income
        }
    }

    /// У перевода нет типа категории.
    var entryType: TransactionType? {
        switch self {
        case .expense: .expense
        case .income: .income
        case .transfer: nil
        }
    }
}

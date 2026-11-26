import SwiftUI

extension DS {
    enum CategoryForm {
        static let previewSide: CGFloat = 64
        static let iconCellHeight: CGFloat = 48
        static let iconCellRadius: CGFloat = 10
    }
}

extension DS.AccountColor {
    /// Hex remains the storage format for categories. These are the light palette values.
    var categoryHex: String {
        switch self {
        case .yellow: "#FFD60A"
        case .green: "#8EE3A1"
        case .blue: "#9CC8FF"
        case .red: "#FFB0A8"
        case .purple: "#D4B5FF"
        case .orange: "#FFC78A"
        case .teal: "#8FE0D6"
        case .pink: "#FFB3CF"
        case .lime: "#D6F08A"
        case .cyan: "#B8E3FF"
        case .indigo: "#C8D0FF"
        case .black: "#111111"
        }
    }

    init(categoryHex: String) {
        self = Self(rawValue: DS.CategoryColor(legacyHex: categoryHex).rawValue) ?? .green
    }
}

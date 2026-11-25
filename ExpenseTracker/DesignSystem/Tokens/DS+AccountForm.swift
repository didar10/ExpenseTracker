import SwiftUI

extension DS {
    /// Размеры из AccountForm.html и AccountFormEdit.html.
    enum AccountForm {
        static let spacing: CGFloat = 14
        static let previewHeight: CGFloat = 120
        static let previewRadius: CGFloat = 16
        static let previewVerticalPadding: CGFloat = 14
        static let iconSize: CGFloat = 34
        static let iconRadius: CGFloat = 9
        static let paletteColumns = 6
        static let paletteSpacing: CGFloat = 10
        static let swatchHeight: CGFloat = 40
        static let swatchRadius: CGFloat = 10
        static let selectionGap: CGFloat = 3
        static let selectionWidth: CGFloat = 2
        static let editTitleSize: CGFloat = 17
        static let minimumScale: CGFloat = 0.7
    }

    /// Двенадцать цветов в порядке макета; строковое значение остается в Account.color.
    enum AccountColor: String, CaseIterable {
        case yellow, green, blue, red, purple, orange
        case teal, pink, lime, cyan, indigo, black

        init(name: String) {
            switch name.lowercased() {
            case "mint": self = .lime
            case "brown": self = .orange
            default: self = Self(rawValue: name.lowercased()) ?? .blue
            }
        }

        var color: SwiftUI.Color {
            switch self {
            case .yellow: return Color.accent
            case .green: return CategoryColor.green.color
            case .blue: return CategoryColor.blue.color
            case .red: return Color.accountRed
            case .purple: return CategoryColor.purple.color
            case .orange: return CategoryColor.orange.color
            case .pink: return CategoryColor.pink.color
            case .black: return Color.onAccent
            case .teal, .lime, .cyan, .indigo: return SwiftUI.Color("DS/account\(rawValue.capitalized)")
            }
        }

        var foreground: SwiftUI.Color {
            switch self {
            case .yellow: return Color.onAccent
            case .black: return Color.onDanger
            default: return Color.ink
            }
        }

        var accessibilityName: String {
            NSLocalizedString("account_color_\(rawValue)", comment: "Цвет счета")
        }
    }
}

extension DS.Font {
    static let accountFormEditTitle = SwiftUI.Font.custom(DS.FontName.unboundedBold.rawValue, size: DS.AccountForm.editTitleSize, relativeTo: .headline)
}

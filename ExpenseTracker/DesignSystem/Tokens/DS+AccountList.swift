import SwiftUI

extension DS {
    /// `AccountSelection*.html`: .li, .sq, .st и кнопки редактирования
    enum AccountList {
        static let minimumScale: CGFloat = 0.75
        static let rowHeight: CGFloat = 62
        static let iconWidth: CGFloat = 46
        static let iconHeight: CGFloat = 32
        static let iconRadius: CGFloat = 7
        static let badgeHeight: CGFloat = 18
        static let badgeFont: CGFloat = 10
        static let deleteSize: CGFloat = 26
        static let trailingPadding: CGFloat = 14
        static let headerButtonHeight: CGFloat = 34
        static let headerBottom: CGFloat = 14
        static let emptyIconSize: CGFloat = 60
        static let emptyIconRadius: CGFloat = 14
        static let emptyVerticalPadding: CGFloat = 24
        static let initialSheetHeight: CGFloat = 440
        static let minimumSheetHeight: CGFloat = 200
    }
}

extension DS {
    /// Именованные цвета старых счетов переводятся в плоскую палитру дизайн-системы.
    static func accountColor(named name: String) -> SwiftUI.Color {
        AccountColor(name: name).color
    }
}

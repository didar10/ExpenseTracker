import SwiftUI

extension DS {
    enum Settings {
        static let sectionSpacing: CGFloat = 22
        static let labelInset: CGFloat = 2
        static let rowHeight: CGFloat = 56
        static let rowTrailing: CGFloat = 14
        static let subtitleSpacing: CGFloat = 2
        static let footerTop: CGFloat = 26
    }
}

extension DS.Font {
    /// Название приложения в подписи версии.
    static let appName = SwiftUI.Font.custom(DS.FontName.unboundedBold.rawValue, size: 16, relativeTo: .headline)
}

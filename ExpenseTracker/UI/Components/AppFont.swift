//
//  AppFont.swift
//  ExpenseTracker
//
//  Created by Didar on 04.01.2026.
//

import SwiftUI

enum AppFont {

    case largeTitle
    case onboardingTitle
    case balance
    case title
    case section
    case sectionHeader
    case body
    case bodySmaller
    case bodySmall
    case caption
    case captionMedium
    case microCaption
    case microCaptionStrong

    var font: Font {
        .custom(fontName, size: size)
    }

    /// Тот же шрифт для UIKit — для полей, которых нет в SwiftUI.
    /// Масштабируется с Dynamic Type, как и `font`
    var uiFont: UIFont {
        let base = UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size)
        return UIFontMetrics.default.scaledFont(for: base)
    }

    private var fontName: String {
        switch self {
        case .largeTitle: return "Montserrat-SemiBold"
        case .onboardingTitle: return "Montserrat-SemiBold"
        case .balance: return "Montserrat-Bold"
        case .title: return "Montserrat-SemiBold"
        case .section: return "Montserrat-SemiBold"
        case .sectionHeader: return "Montserrat-SemiBold"
        case .body: return "Montserrat-Regular"
        case .bodySmaller: return "Montserrat-Medium"
        case .bodySmall: return "Montserrat-SemiBold"
        case .caption: return "Montserrat-Regular"
        case .captionMedium: return "Montserrat-SemiBold"
        case .microCaption: return "Montserrat-Medium"
        case .microCaptionStrong: return "Montserrat-SemiBold"
        }
    }

    private var size: CGFloat {
        switch self {
        case .largeTitle: return 38
        case .onboardingTitle: return 28
        case .balance: return 40
        case .title: return 20
        case .section: return 18
        case .sectionHeader: return 14
        case .body: return 16
        case .bodySmaller: return 15
        case .bodySmall: return 15
        case .caption: return 13
        case .captionMedium: return 13
        case .microCaption: return 10
        case .microCaptionStrong: return 10
        }
    }
}

extension Font {
    static func app(_ style: AppFont) -> Font {
        style.font
    }
}

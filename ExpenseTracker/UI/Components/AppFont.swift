//
//  AppFont.swift
//  ExpenseTracker
//
//  Created by Didar on 04.01.2026.
//

import SwiftUI

enum AppFont {

    case largeTitle
    case title
    case section
    case body
    case caption

    var font: Font {
        switch self {

        case .largeTitle:
            return .custom("Montserrat-SemiBold", size: 38)

        case .title:
            return .custom("Montserrat-SemiBold", size: 20)

        case .section:
            return .custom("Montserrat-SemiBold", size: 18)

        case .body:
            return .custom("Montserrat-Regular", size: 16)

        case .caption:
            return .custom("Montserrat-Regular", size: 13)
        }
    }
}

extension Font {
    static func app(_ style: AppFont) -> Font {
        style.font
    }
}

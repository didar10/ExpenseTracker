//
//  AppFont.swift
//  ExpenseTracker
//
//  Created by Didar on 04.01.2026.
//

import SwiftUI

enum AppFont {

    case largeTitle
    case balance
    case title
    case section
    case sectionHeader
    case body
    case bodySmaller
    case bodySmall
    case caption
    case microCaption

    var font: Font {
        switch self {

        case .largeTitle:
            return .custom("Montserrat-SemiBold", size: 38)
            
        case .balance:
            return .custom("Montserrat-Bold", size: 40)

        case .title:
            return .custom("Montserrat-SemiBold", size: 20)

        case .section:
            return .custom("Montserrat-SemiBold", size: 18)
            
        case .sectionHeader:
            return .custom("Montserrat-SemiBold", size: 14)

        case .body:
            return .custom("Montserrat-Regular", size: 16)
        
        case .bodySmaller:
            return .custom("Montserrat-Medium", size: 15)
            
        case .bodySmall:
            return .custom("Montserrat-SemiBold", size: 15)

        case .caption:
            return .custom("Montserrat-Regular", size: 13)
            
        case .microCaption:
            return .custom("Montserrat-Medium", size: 10)
        }
    }
}

extension Font {
    static func app(_ style: AppFont) -> Font {
        style.font
    }
}

//
//  AppText.swift
//  ExpenseTracker
//
//  Created by Didar on 24.01.2026.
//

import SwiftUI

struct AppText: View {
    let text: String
    let style: AppFont
    var color: Color = .primary
    var alignment: TextAlignment = .leading
    
    init(_ text: String, style: AppFont, color: Color = .primary, alignment: TextAlignment = .leading) {
        self.text = text
        self.style = style
        self.color = color
        self.alignment = alignment
    }
    
    var body: some View {
        Text(text)
            .font(.app(style))
            .foregroundStyle(color)
            .multilineTextAlignment(alignment)
    }
}

// MARK: - Convenience Modifiers
extension AppText {
    func color(_ color: Color) -> AppText {
        AppText(text, style: style, color: color, alignment: alignment)
    }
    
    func alignment(_ alignment: TextAlignment) -> AppText {
        AppText(text, style: style, color: color, alignment: alignment)
    }
}

#Preview {
    VStack(spacing: 20) {
        AppText("Large Title", style: .largeTitle)
        AppText("Title", style: .title)
        AppText("Section", style: .section)
        AppText("Body Text", style: .body)
        AppText("Caption", style: .caption)
        
        AppText("Colored Text", style: .title, color: .blue)
        AppText("Centered Text", style: .body, alignment: .center)
    }
    .padding()
}

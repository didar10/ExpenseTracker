//
//  HeaderView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Компонент для отображения заголовка
struct HeaderView: View {
    let title: String
    
    var body: some View {
        AppText(title, style: .title)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 16)
            .background(Color.appBackground)
    }
}

#Preview {
    HeaderView(title: "Главная")
}

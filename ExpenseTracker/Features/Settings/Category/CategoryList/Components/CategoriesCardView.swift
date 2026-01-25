//
//  CategoriesCardView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

/// Карточка со списком категорий
struct CategoriesCardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(16)
            .cardShadow(cornerRadius: 20)
    }
}

#Preview {
    CategoriesCardView {
        Text("Content")
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

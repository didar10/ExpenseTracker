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
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(
                        color: .black.opacity(0.65),
                        radius: 0,
                        x: 4,
                        y: 6
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.15), lineWidth: 1.5)
            )
    }
}

#Preview {
    CategoriesCardView {
        Text("Content")
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

//
//  CategoryFormSectionView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

/// Секция формы с лейблом
struct CategoryFormSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            
            content
        }
    }
}

#Preview {
    CategoryFormSectionView(title: "Название") {
        TextField("Введите название", text: .constant(""))
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

//
//  EmptyCategoriesView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

/// Пустое состояние для списка категорий
struct EmptyCategoriesView: View {
    var body: some View {
        CategoriesCardView {
            VStack(spacing: 16) {
                Image(systemName: "folder")
                    .font(.system(size: 56))
                    .foregroundStyle(.tertiary)
                    .symbolRenderingMode(.hierarchical)
                
                VStack(spacing: 8) {
                    Text("Нет категорий")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Text("Нажмите + чтобы добавить категорию")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    EmptyCategoriesView()
        .padding()
        .background(Color(.systemGroupedBackground))
}

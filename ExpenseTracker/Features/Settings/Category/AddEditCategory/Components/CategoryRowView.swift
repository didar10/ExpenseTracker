//
//  CategoryRowView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

/// Строка категории в списке
struct CategoryRowView: View {
    let category: Category
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Иконка категории
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: category.colorHex).opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: category.icon)
                    .foregroundStyle(Color(hex: category.colorHex))
                    .font(.system(size: 20, weight: .semibold))
            }
            
            // Название категории
            Text(category.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
            
            Spacer()
            
            // Кнопки действий
            HStack(spacing: 16) {
                // Кнопка удаления
                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.red.opacity(0.8))
                }
                .buttonStyle(.plain)
                
                // Шеврон для редактирования
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    CategoryRowView(
        category: Category(
            name: "Продукты",
            icon: "cart.fill",
            colorHex: "#FF6B6B"
        ),
        onDelete: {}
    )
    .padding()
}

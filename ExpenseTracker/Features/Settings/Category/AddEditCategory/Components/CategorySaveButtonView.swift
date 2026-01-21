//
//  CategorySaveButtonView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

/// Кнопка сохранения категории
struct CategorySaveButtonView: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isEnabled ? Color.green : Color.gray)
            )
            .shadow(
                color: isEnabled ? Color.green.opacity(0.3) : Color.clear,
                radius: 8,
                y: 4
            )
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
        .padding(.top, 8)
    }
}

#Preview {
    VStack(spacing: 16) {
        CategorySaveButtonView(
            title: "Создать категорию",
            isEnabled: true,
            action: {}
        )
        
        CategorySaveButtonView(
            title: "Создать категорию",
            isEnabled: false,
            action: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

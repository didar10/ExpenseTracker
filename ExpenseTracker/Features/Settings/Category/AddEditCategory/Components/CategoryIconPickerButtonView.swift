//
//  CategoryIconPickerButtonView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

/// Кнопка выбора иконки категории
struct CategoryIconPickerButtonView: View {
    let icon: String
    let colorHex: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Preview текущей иконки
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: colorHex).opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color(hex: colorHex))
                }
                
                Text("Выбрать иконку")
                    .font(.system(size: 17))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(uiColor: .systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CategoryIconPickerButtonView(
        icon: "cart.fill",
        colorHex: "#FF6B6B",
        action: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

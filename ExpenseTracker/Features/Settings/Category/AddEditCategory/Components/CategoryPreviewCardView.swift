//
//  CategoryPreviewCardView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

/// Карточка preview категории
struct CategoryPreviewCardView: View {
    let name: String
    let icon: String
    let colorHex: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Большая иконка в круге
            ZStack {
                Circle()
                    .fill(Color(hex: colorHex).opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: icon)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Color(hex: colorHex))
            }
            
            // Название или placeholder
            Text(name.isEmpty ? "Название категории" : name)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(name.isEmpty ? .secondary : .primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .cardShadow(cornerRadius: 20)
    }
}

#Preview {
    VStack {
        CategoryPreviewCardView(
            name: "Продукты",
            icon: "cart.fill",
            colorHex: "#FF6B6B"
        )
        
        CategoryPreviewCardView(
            name: "",
            icon: "cart.fill",
            colorHex: "#34C759"
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

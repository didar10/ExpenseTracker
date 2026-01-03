//
//  CategoryItemView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI

struct CategoryItemView: View {

    let category: Category
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(Color(hex: category.colorHex))
                    .frame(width: 44, height: 44)

                Image(systemName: category.icon)
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
            }

            Text(category.name)
                .font(.app(.caption))
                .lineLimit(1)
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isSelected ? Color.green : Color.clear,
                    lineWidth: 2
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

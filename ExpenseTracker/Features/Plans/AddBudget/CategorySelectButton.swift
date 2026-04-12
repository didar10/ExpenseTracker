//
//  CategorySelectButton.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI

struct CategorySelectButton: View {

    // MARK: - Properties

    let category: Category
    let isSelected: Bool
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(hex: category.colorHex).opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: category.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color(hex: category.colorHex))
                }

                Text(category.name)
                    .font(.app(.caption))
                    .foregroundStyle(isSelected ? AppColor.textPrimary : AppColor.textSecondary)
                    .lineLimit(1)
            }
            .padding(12)
            .background(isSelected ? AppColor.accent.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? AppColor.accent : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

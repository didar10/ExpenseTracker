//
//  CategoryRowView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

struct CategoryRowView: View {

    // MARK: - Properties

    let category: Category
    let onDelete: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: category.colorHex).opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: category.icon)
                    .foregroundStyle(Color(hex: category.colorHex))
                    .font(.system(size: 20, weight: .semibold))
            }

            Text(category.name)
                .font(.app(.bodySmaller))
                .foregroundStyle(AppColor.textPrimary)

            Spacer()

            HStack(spacing: 16) {
                Button(action: onDelete) {
                    AppImage.trashFill
                        .font(.system(size: 16))
                        .foregroundStyle(AppColor.expense.opacity(0.8))
                }
                .buttonStyle(.plain)

                AppImage.chevronRight
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
        category: Category(name: "Продукты", icon: "cart.fill", colorHex: "#FF6B6B"),
        onDelete: {}
    )
    .padding()
}

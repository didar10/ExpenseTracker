//
//  AllCategoriesView.swift
//  ExpenseTracker
//
//  Created by Didar on 23.01.2026.
//

import SwiftUI

struct AllCategoriesView: View {
    let categories: [Category]
    let selectedCategory: Category?
    let onSelect: (Category) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(categories) { category in
                    AllCategoriesItemView(
                        category: category,
                        isSelected: selectedCategory?.id == category.id
                    )
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onSelect(category)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Все категории")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - All Categories Item View

struct AllCategoriesItemView: View {
    let category: Category
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color(hex: category.colorHex) : Color(.secondarySystemGroupedBackground))
                    .frame(width: 56, height: 56)
                    .shadow(
                        color: isSelected ? Color(hex: category.colorHex).opacity(0.3) : .clear,
                        radius: isSelected ? 6 : 0,
                        y: isSelected ? 3 : 0
                    )

                Image(systemName: category.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : .secondary)
                    .symbolEffect(.bounce, value: isSelected)
            }
            
            Text(category.name)
                .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .frame(height: 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        }
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

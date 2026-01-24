//
//  CategorySelectionView.swift
//  ExpenseTracker
//
//  Created by Didar on 23.01.2026.
//

import SwiftUI

struct CategorySelectionView: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    let onShowAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                ForEach(Array(categories.prefix(4))) { category in
                    CategoryItemView(
                        category: category,
                        isSelected: selectedCategory?.id == category.id
                    )
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                    }
                }
                
                // Circular "More" button
                MoreCategoriesButton(onTap: onShowAll)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Category Item View

struct CategoryItemView: View {
    let category: Category
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(hex: category.colorHex).opacity(isSelected ? 1.0 : 0.15))
                    .frame(width: 54, height: 54)
                    .overlay {
                        if isSelected {
                            Circle()
                                .strokeBorder(Color(hex: category.colorHex).opacity(0.3), lineWidth: 3)
                                .scaleEffect(1.15)
                        }
                    }

                Image(systemName: category.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : Color(hex: category.colorHex))
                    .symbolEffect(.bounce, value: isSelected)
            }
            
            Text(category.name)
                .font(.app(.microCaption))
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundStyle(isSelected ? .primary : .secondary)
                .lineLimit(2)
                .truncationMode(.tail)
                .multilineTextAlignment(.center)
                .frame(width: 64)
        }
    }
}

// MARK: - More Categories Button

struct MoreCategoriesButton: View {
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(width: 54, height: 54)
                Image(systemName: "ellipsis")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            AppText("Еще", style: .microCaption, color: .secondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .multilineTextAlignment(.center)
                .frame(width: 64)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        }
    }
}

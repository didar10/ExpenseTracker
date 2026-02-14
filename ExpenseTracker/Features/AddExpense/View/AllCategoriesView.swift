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
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    if categories.isEmpty {
                        emptyStateView
                    } else {
                        categoriesGrid
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Все категории")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                ToolbarIconButton(icon: "chevron.left") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    AddEditCategoryView()
                } label: {
                    ToolbarIconButtonLabel(icon: "plus")
                }
            }
        }
    }
    
    private var categoriesGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            ForEach(categories) { category in
                categoryGridItem(category)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onSelect(category)
                    }
            }
        }
    }
    
    private func categoryGridItem(_ category: Category) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(hex: category.colorHex).opacity(selectedCategory?.id == category.id ? 1.0 : 0.15))
                    .frame(width: 56, height: 56)
                    .overlay {
                        if selectedCategory?.id == category.id {
                            Circle()
                                .strokeBorder(Color(hex: category.colorHex).opacity(0.3), lineWidth: 2.5)
                                .scaleEffect(1.15)
                        }
                    }

                Image(systemName: category.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(selectedCategory?.id == category.id ? .white : Color(hex: category.colorHex))
                    .symbolEffect(.bounce, value: selectedCategory?.id == category.id)
            }
            
            Text(category.name)
                .font(.system(size: 12, weight: selectedCategory?.id == category.id ? .semibold : .medium))
                .foregroundStyle(selectedCategory?.id == category.id ? .primary : .secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .frame(height: 32)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Нет категорий")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)
            
            Text("Создайте категорию")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            NavigationLink {
                AddEditCategoryView()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    
                    Text("Создать категорию")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.blue)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background {
                    Capsule()
                        .fill(Color.blue.opacity(0.1))
                }
            }
        }
        .padding()
    }
}



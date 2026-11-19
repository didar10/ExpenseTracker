//
//  AllCategoriesView.swift
//  ExpenseTracker
//
//  Created by Didar on 23.01.2026.
//

import SwiftUI

struct AllCategoriesView: View {

    // MARK: - Properties

    let categories: [Category]
    let selectedCategory: Category?
    let onSelect: (Category) -> Void

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColor.background
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
        .navigationTitle(AppString.allCategories)
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
}

// MARK: - Subviews
private extension AllCategoriesView {

    var categoriesGrid: some View {
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

    func categoryGridItem(_ category: Category) -> some View {
        let isSelected = selectedCategory?.id == category.id

        return VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(hex: category.colorHex).opacity(isSelected ? 1.0 : 0.15))
                    .frame(width: 56, height: 56)
                    .overlay {
                        if isSelected {
                            Circle()
                                .strokeBorder(Color(hex: category.colorHex).opacity(0.3), lineWidth: 2.5)
                                .scaleEffect(1.15)
                        }
                    }

                Image(systemName: category.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(isSelected ? AppColor.textWhite : Color(hex: category.colorHex))
                    .symbolEffect(.bounce, value: isSelected)
            }

            Text(category.name)
                .font(.app(.microCaption))
                .foregroundStyle(isSelected ? AppColor.textPrimary : AppColor.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .frame(height: 32)
        }
        .frame(maxWidth: .infinity)
    }

    var emptyStateView: some View {
        VStack(spacing: 20) {
            AppImage.categoriesGrid
                .font(.system(size: 60))
                .foregroundStyle(AppColor.textSecondary)

            AppText(AppString.noCategories, style: .title)

            AppText(AppString.createCategoryHint, style: .body)
                .color(AppColor.textSecondary)
                .multilineTextAlignment(.center)

            NavigationLink {
                AddEditCategoryView()
            } label: {
                HStack(spacing: 8) {
                    AppImage.plusCircleFill
                        .font(.system(size: 20))

                    AppText(AppString.createCategory, style: .bodySmaller)
                }
                .foregroundStyle(AppColor.accent)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background {
                    Capsule()
                        .fill(AppColor.accent.opacity(0.1))
                }
            }
        }
        .padding()
    }
}

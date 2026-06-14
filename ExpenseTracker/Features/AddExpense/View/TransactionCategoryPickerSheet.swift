//
//  TransactionCategoryPickerSheet.swift
//  ExpenseTracker
//
//  Created by Didar on 23.05.2026.
//

import SwiftUI

struct TransactionCategoryPickerSheet: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss

    let categories: [Category]
    let selectedCategory: Category?
    let onSelect: (Category) -> Void

    @State private var searchText = ""

    // MARK: - Computed Properties

    private var filteredCategories: [Category] {
        if searchText.isEmpty {
            return categories
        }
        return categories.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                if categories.isEmpty {
                    emptyState
                } else {
                    searchBar
                    categoriesGrid
                }
            }
        }
    }
}

// MARK: - Subviews
private extension TransactionCategoryPickerSheet {

    var header: some View {
        ZStack {
            AppText(AppString.selectCategory, style: .section)

            HStack {
                ToolbarIconButton(icon: "xmark", isOutlined: true) {
                    dismiss()
                }

                Spacer()
            }
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.small)
    }

    var searchBar: some View {
        HStack(spacing: AppSpacing.small) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColor.textSecondary)

            TextField(AppString.searchCategory, text: $searchText)
                .font(.app(.body))
        }
        .padding(AppSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColor.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .strokeBorder(
                    AppColor.textPrimary.opacity(0.15),
                    lineWidth: AppSpacing.hairline
                )
        )
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.medium)
    }

    var categoriesGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppSpacing.medium),
                    GridItem(.flexible(), spacing: AppSpacing.medium),
                    GridItem(.flexible(), spacing: AppSpacing.medium),
                    GridItem(.flexible(), spacing: AppSpacing.medium)
                ],
                spacing: AppSpacing.large
            ) {
                ForEach(filteredCategories) { category in
                    Button {
                        onSelect(category)
                    } label: {
                        categoryItem(category)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.vertical, AppSpacing.medium)
        }
    }

    func categoryItem(_ category: Category) -> some View {
        let isSelected = selectedCategory?.id == category.id
        let color = Color(hex: category.colorHex)

        return VStack(spacing: AppSpacing.small) {
            ZStack {
                Circle()
                    .fill(isSelected ? color : Color.clear)
                    .frame(width: AppSize.iconXXLarge, height: AppSize.iconXXLarge)
                    .overlay {
                        Circle()
                            .strokeBorder(color, lineWidth: 1.5)
                    }

                Image(systemName: category.icon)
                    .font(.system(size: AppSize.glyphXXLarge, weight: .regular))
                    .foregroundStyle(isSelected ? AppColor.textWhite : color)
            }

            Text(category.name)
                .font(.app(.caption))
                .foregroundStyle(isSelected ? AppColor.textPrimary : AppColor.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }

    var emptyState: some View {
        VStack(spacing: AppSpacing.xLarge) {
            AppImage.categoriesGrid
                .font(.system(size: AppSize.glyphEmptyState))
                .foregroundStyle(AppColor.textSecondary)

            AppText(AppString.noCategories, style: .title)

            AppText(AppString.createCategoryHint, style: .body)
                .color(AppColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppSpacing.xLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

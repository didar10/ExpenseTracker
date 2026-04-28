//
//  CategoryPickerSheet.swift
//  ExpenseTracker
//
//  Created by Didar on 25.04.2026.
//

import SwiftUI

struct CategoryPickerSheet: View {

    // MARK: - Properties

    let categories: [Category]
    let selectedCategory: Category?
    let onSelect: (Category?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                searchBar
                categoryList
            }
        }
    }
}

// MARK: - Subviews
private extension CategoryPickerSheet {

    var header: some View {
        ZStack {
            AppText(AppString.selectCategory, style: .section)

            HStack {
                Spacer()

                ToolbarIconButton(icon: "xmark", isOutlined: true) {
                    dismiss()
                }
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

    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return categories
        }
        return categories.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var showsAllCategoriesCard: Bool {
        searchText.isEmpty ||
        AppString.allCategories.localizedCaseInsensitiveContains(searchText)
    }

    var categoryList: some View {
        ScrollView {
            VStack(spacing: AppSpacing.small) {
                if showsAllCategoriesCard {
                    allCategoriesCard

                    if !filteredCategories.isEmpty {
                        Rectangle()
                            .fill(AppColor.textPrimary.opacity(0.08))
                            .frame(height: AppSpacing.hairline)
                            .padding(.vertical, AppSpacing.xSmall)
                    }
                }

                ForEach(filteredCategories) { category in
                    categoryCard(category)
                }
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.vertical, AppSpacing.small)
        }
    }

    var allCategoriesCard: some View {
        let isSelected = selectedCategory == nil

        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onSelect(nil)
            dismiss()
        } label: {
            cardContent(
                iconView: AnyView(
                    ZStack {
                        RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous)
                            .fill(AppColor.textPrimary.opacity(0.08))
                            .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)

                        Image(systemName: "square.grid.2x2.fill")
                            .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                            .foregroundStyle(AppColor.textPrimary)
                    }
                ),
                title: AppString.allCategories,
                isSelected: isSelected
            )
        }
        .buttonStyle(.plain)
    }

    func categoryCard(_ category: Category) -> some View {
        let isSelected = selectedCategory?.persistentModelID == category.persistentModelID
        let tint = Color(hex: category.colorHex)

        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onSelect(category)
            dismiss()
        } label: {
            cardContent(
                iconView: AnyView(
                    ZStack {
                        RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous)
                            .fill(tint.opacity(0.18))
                            .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)

                        Image(systemName: category.icon)
                            .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                            .foregroundStyle(tint)
                    }
                ),
                title: category.name,
                isSelected: isSelected
            )
        }
        .buttonStyle(.plain)
    }

    func cardContent(iconView: AnyView, title: String, isSelected: Bool) -> some View {
        HStack(spacing: AppSpacing.medium) {
            iconView

            AppText(title, style: .body)

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: AppSize.glyphXLarge, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
            }
        }
        .padding(AppSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColor.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .strokeBorder(
                    isSelected
                        ? AppColor.textPrimary
                        : AppColor.textPrimary.opacity(0.1),
                    lineWidth: isSelected ? AppSpacing.hairline + 0.5 : AppSpacing.hairline
                )
        )
    }
}

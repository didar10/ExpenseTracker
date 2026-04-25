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
                categoryGrid
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

    var categoryGrid: some View {
        ScrollView {
            FlowLayout(spacing: AppSpacing.small) {
                noCategoryPill

                ForEach(filteredCategories) { category in
                    categoryPill(category)
                }
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.vertical, AppSpacing.small)
        }
    }

    var noCategoryPill: some View {
        let isSelected = selectedCategory == nil

        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onSelect(nil)
            dismiss()
        } label: {
            HStack(spacing: AppSpacing.small) {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray4).opacity(0.2))
                        .frame(width: 32, height: 32)

                    Image(systemName: "minus")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(isSelected ? Color(.systemBackground) : AppColor.textSecondary)
                }

                AppText(
                    AppString.noCategory,
                    style: .bodySmall,
                    color: isSelected ? Color(.systemBackground) : AppColor.textPrimary
                )
            }
            .padding(.leading, AppSpacing.xSmall)
            .padding(.trailing, AppSpacing.large)
            .padding(.vertical, AppSpacing.xSmall)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? AppColor.textPrimary : AppColor.cardBackground)
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(
                        AppColor.textPrimary,
                        lineWidth: AppSpacing.hairline
                    )
            )
        }
        .buttonStyle(.plain)
    }

    func categoryPill(_ category: Category) -> some View {
        let isSelected = selectedCategory?.persistentModelID == category.persistentModelID

        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onSelect(category)
            dismiss()
        } label: {
            HStack(spacing: AppSpacing.small) {
                ZStack {
                    Circle()
                        .fill(Color(hex: category.colorHex).opacity(0.2))
                        .frame(width: 32, height: 32)

                    Image(systemName: category.icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(isSelected ? Color(.systemBackground) : Color(hex: category.colorHex))
                }

                AppText(
                    category.name,
                    style: .bodySmall,
                    color: isSelected ? Color(.systemBackground) : AppColor.textPrimary
                )
            }
            .padding(.leading, AppSpacing.xSmall)
            .padding(.trailing, AppSpacing.large)
            .padding(.vertical, AppSpacing.xSmall)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? AppColor.textPrimary : AppColor.cardBackground)
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(
                        AppColor.textPrimary,
                        lineWidth: AppSpacing.hairline
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

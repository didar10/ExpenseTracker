//
//  CategorySelectionView.swift
//  ExpenseTracker
//
//  Created by Didar on 23.01.2026.
//

import SwiftUI
import SwiftData

struct CategorySelectionView: View {

    // MARK: - Properties

    let categories: [Category]
    let type: TransactionType
    @Binding var selectedCategory: Category?

    @Query private var transactions: [Transaction]

    @State private var pinnedCategoryID: UUID?
    @State private var showingPicker = false

    private let frequentCount = 4

    // MARK: - Computed Properties

    private var usageCounts: [UUID: Int] {
        var counts: [UUID: Int] = [:]
        for transaction in transactions where transaction.type == type {
            guard let id = transaction.category?.id else { continue }
            counts[id, default: 0] += 1
        }
        return counts
    }

    private var frequentCategories: [Category] {
        categories.sorted { lhs, rhs in
            let lhsCount = usageCounts[lhs.id] ?? 0
            let rhsCount = usageCounts[rhs.id] ?? 0
            if lhsCount != rhsCount { return lhsCount > rhsCount }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    private var displayCategories: [Category] {
        var result: [Category] = []

        if let pinnedID = pinnedCategoryID,
           let pinned = categories.first(where: { $0.id == pinnedID }) {
            result.append(pinned)
        }

        for category in frequentCategories {
            if result.count >= frequentCount { break }
            if !result.contains(where: { $0.id == category.id }) {
                result.append(category)
            }
        }

        return result
    }

    // MARK: - Body

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.small) {
            ForEach(displayCategories) { category in
                categoryItem(category)
                    .frame(maxWidth: .infinity)
            }

            moreButton
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, AppSpacing.xSmall)
        .padding(.vertical, AppSpacing.small)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: displayCategories.map(\.id))
        .sheet(isPresented: $showingPicker) {
            CategoriesListView(onSelect: handleSheetSelection, initialType: type)
        }
    }

    // MARK: - Actions

    private func handleSheetSelection(_ category: Category) {
        pinnedCategoryID = category.id
        selectedCategory = category
    }

    private func handleCategoryTap(_ category: Category) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if selectedCategory?.id == category.id {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }
    }
}

// MARK: - Subviews
private extension CategorySelectionView {

    func categoryItem(_ category: Category) -> some View {
        let isSelected = selectedCategory?.id == category.id
        let color = Color(hex: category.colorHex)

        return Button {
            handleCategoryTap(category)
        } label: {
            VStack(spacing: AppSpacing.small) {
                ZStack {
                    Circle()
                        .fill(isSelected ? color : color.opacity(0.2))
                        .frame(width: AppSize.iconLarge, height: AppSize.iconLarge)

                    Image(systemName: category.icon)
                        .font(.system(size: AppSize.glyphXLarge, weight: .regular))
                        .foregroundStyle(AppColor.textPrimary)
                }

                Text(category.name)
                    .font(.app(.microCaption))
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.plain)
    }

    var moreButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            showingPicker = true
        } label: {
            VStack(spacing: AppSpacing.small) {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: AppSize.iconLarge, height: AppSize.iconLarge)

                    Image(systemName: "ellipsis")
                        .font(.system(size: AppSize.glyphXLarge, weight: .regular))
                        .foregroundStyle(AppColor.textSecondary)
                }

                Text(AppString.more)
                    .font(.app(.microCaption))
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.plain)
    }
}

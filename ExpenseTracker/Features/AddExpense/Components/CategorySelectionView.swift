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

    @State private var usageCounts: [UUID: Int] = [:]
    @State private var pinnedCategoryID: UUID?
    @State private var showingPicker = false

    private let frequentCount = 4

    // MARK: - Computed Properties

    /// Частые категории сверху; счетчики пересчитываются не на каждый рендер, а по `task(id:)`
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

        if let pinnedCategoryID,
           let pinned = categories.first(where: { $0.id == pinnedCategoryID }) {
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
            if displayCategories.isEmpty {
                emptyState
            } else {
                ForEach(displayCategories) { category in
                    categoryItem(category)
                        .frame(maxWidth: .infinity)
                }
            }

            moreButton
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, AppSpacing.xSmall)
        .padding(.vertical, AppSpacing.small)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: displayCategories.map(\.id))
        .sensoryFeedback(.selection, trigger: selectedCategory?.id)
        .task(id: usageKey) { recalculateUsageCounts() }
        .sheet(isPresented: $showingPicker) {
            CategoriesListView(onSelect: handleSheetSelection, initialType: type)
        }
    }

    // MARK: - Actions

    /// Пересчет нужен при смене типа и при появлении новых операций, а не на каждый проход `body`
    private var usageKey: String {
        "\(type.rawValue)-\(transactions.count)"
    }

    private func recalculateUsageCounts() {
        var counts: [UUID: Int] = [:]

        for transaction in transactions where transaction.type == type {
            guard let id = transaction.category?.id else { continue }
            counts[id, default: 0] += 1
        }

        usageCounts = counts
    }

    private func handleSheetSelection(_ category: Category) {
        pinnedCategoryID = category.id
        selectedCategory = category
    }

    private func handleCategoryTap(_ category: Category) {
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
                        .fill(color.opacity(isSelected ? 1 : 0.2))
                        .frame(width: AppSize.iconLarge, height: AppSize.iconLarge)

                    Image(systemName: category.icon)
                        .font(.system(size: AppSize.glyphXLarge, weight: .regular))
                        .foregroundStyle(isSelected ? AppColor.textWhite : AppColor.textPrimary)
                }

                Text(category.name)
                    .font(.app(isSelected ? .microCaptionStrong : .microCaption))
                    .foregroundStyle(isSelected ? AppColor.textPrimary : AppColor.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(PressableScaleButtonStyle())
        .accessibilityLabel(category.name)
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }

    var moreButton: some View {
        Button {
            showingPicker = true
        } label: {
            VStack(spacing: AppSpacing.small) {
                ZStack {
                    Circle()
                        .fill(AppColor.neutralFill)
                        .frame(width: AppSize.iconLarge, height: AppSize.iconLarge)

                    AppImage.ellipsis
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
        .buttonStyle(PressableScaleButtonStyle())
        .accessibilityLabel(AppString.allCategories)
    }

    /// Для выбранного типа операций категорий еще нет — объясняем, где их создать
    var emptyState: some View {
        Text(AppString.noCategoriesForType)
            .font(.app(.caption))
            .foregroundStyle(AppColor.textSecondary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, AppSpacing.small)
            .frame(height: AppSize.inlineTile)
    }
}

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

    @State private var scrolledID: UUID?
    @State private var showAddCategory = false

    private let addButtonID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    private let noCategoryID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    private let normalSize: CGFloat = 38
    private let selectedSize: CGFloat = 46
    private let itemWidth: CGFloat = 46

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    addCategoryItem()
                        .id(addButtonID)

                    noCategoryItem(isSelected: scrolledID == noCategoryID)
                        .id(noCategoryID)

                    ForEach(categories) { category in
                        let isSelected = category.id == scrolledID
                        categoryItem(category, isSelected: isSelected)
                            .id(category.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrolledID, anchor: .center)
            .contentMargins(
                .horizontal,
                (geometry.size.width - itemWidth) / 2,
                for: .scrollContent
            )
        }
        .frame(height: selectedSize * 1.2 + 20)
        .onChange(of: scrolledID) { _, newID in
            guard let newID else { return }
            if newID == addButtonID {
                showAddCategory = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        scrolledID = selectedCategory?.id ?? noCategoryID
                    }
                }
                return
            }
            if newID == noCategoryID {
                selectedCategory = nil
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                return
            }
            guard let category = categories.first(where: { $0.id == newID }) else { return }
            selectedCategory = category
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        .onAppear {
            scrolledID = selectedCategory?.id ?? noCategoryID
        }
        .navigationDestination(isPresented: $showAddCategory) {
            AddEditCategoryView()
        }
    }

    // MARK: - Category Item

    private func categoryItem(_ category: Category, isSelected: Bool) -> some View {
        let size = isSelected ? selectedSize : normalSize
        let iconSize: CGFloat = isSelected ? 18 : 16

        return VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Color(hex: category.colorHex).opacity(isSelected ? 1.0 : 0.15))
                    .frame(width: size, height: size)
                    .overlay {
                        if isSelected {
                            Circle()
                                .strokeBorder(
                                    Color(hex: category.colorHex).opacity(0.3),
                                    lineWidth: 2.5
                                )
                                .scaleEffect(1.15)
                        }
                    }

                Image(systemName: category.icon)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : Color(hex: category.colorHex))
                    .animation(nil, value: isSelected)
            }
            .frame(width: selectedSize * 1.2, height: selectedSize * 1.2)

            if isSelected {
                Text(category.name)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
        .frame(width: itemWidth)
        .opacity(isSelected ? 1.0 : 0.6)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isSelected)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                scrolledID = category.id
            }
        }
    }

    // MARK: - No Category Item

    private func noCategoryItem(isSelected: Bool) -> some View {
        let size = isSelected ? selectedSize : normalSize
        let iconSize: CGFloat = isSelected ? 18 : 16

        return VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray4).opacity(isSelected ? 1.0 : 0.15))
                    .frame(width: size, height: size)
                    .overlay {
                        if isSelected {
                            Circle()
                                .strokeBorder(
                                    Color(.systemGray4).opacity(0.3),
                                    lineWidth: 2.5
                                )
                                .scaleEffect(1.15)
                        }
                    }

                Image(systemName: "minus")
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : Color(.systemGray))
                    .animation(nil, value: isSelected)
            }
            .frame(width: selectedSize * 1.2, height: selectedSize * 1.2)

            if isSelected {
                Text("Без категории")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
        .frame(width: itemWidth)
        .opacity(isSelected ? 1.0 : 0.6)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isSelected)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                scrolledID = noCategoryID
            }
        }
    }

    // MARK: - Add Category Button

    private func addCategoryItem() -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .strokeBorder(
                        Color(.tertiaryLabel),
                        style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])
                    )
                    .frame(width: normalSize, height: normalSize)

                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .frame(width: selectedSize * 1.2, height: selectedSize * 1.2)
        }
        .frame(width: itemWidth)
        .opacity(0.5)
    }
}

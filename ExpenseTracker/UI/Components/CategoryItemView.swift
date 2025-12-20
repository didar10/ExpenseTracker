//
//  CategoryItemView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI

struct CategoryItemView: View {

    let category: Category
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.title2)
                .frame(width: 48, height: 48)
                .background(Color.green.opacity(isSelected ? 0.4 : 0.2))
                .clipShape(Circle())

            Text(category.name)
                .font(.caption)
        }
    }
}


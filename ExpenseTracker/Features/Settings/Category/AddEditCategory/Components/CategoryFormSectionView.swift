//
//  CategoryFormSectionView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

struct CategoryFormSectionView<Content: View>: View {

    // MARK: - Properties

    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppText(title, style: .bodySmall, color: AppColor.textSecondary)
                .padding(.horizontal, 4)

            content
        }
    }
}

#Preview {
    CategoryFormSectionView(title: AppString.name) {
        TextField(AppString.enterName, text: .constant(""))
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColor.cardBackground)
            )
    }
    .padding()
    .background(AppColor.background)
}

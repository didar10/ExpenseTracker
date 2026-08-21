//
//  AppCardView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.08.2026.
//

import SwiftUI

/// Универсальная карточка контента в стиле списка категорий
struct AppCardView<Content: View>: View {

    // MARK: - Properties

    let cornerRadius: CGFloat
    let padding: CGFloat
    let content: Content

    // MARK: - Init

    init(
        cornerRadius: CGFloat = AppRadius.xLarge,
        padding: CGFloat = AppSpacing.large,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    // MARK: - Body

    var body: some View {
        content
            .padding(padding)
            .card(cornerRadius: cornerRadius)
    }
}

#Preview {
    AppCardView {
        AppText("Content", style: .body)
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

//
//  DSPreviewGallery.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

#if DEBUG

import SwiftUI

/// Лист состояний компонента для `#Preview`: фон экрана, отступы, прокрутка
struct DSPreviewGallery<Content: View>: View {

    // MARK: - Properties

    @ViewBuilder let content: Content

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Spacing.xl) {
                content
            }
            .padding(DS.Spacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(DS.Color.bg)
    }
}

/// Одно состояние с подписью
struct DSPreviewCase<Content: View>: View {

    // MARK: - Properties

    let title: String
    @ViewBuilder let content: Content

    // MARK: - Init

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text(title)
                .dsLabel()

            content
        }
    }
}

#endif

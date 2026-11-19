//
//  LegalDocumentView.swift
//  ExpenseTracker
//
//  Created by Didar on 02.09.2026.
//

import SwiftUI

/// Экран правового документа: вводная карточка и пронумерованные разделы
struct LegalDocumentView: View {

    // MARK: - Properties

    let document: LegalDocument

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                SheetHeaderView(title: document.shortTitle) {
                    dismiss()
                }

                ScrollView {
                    VStack(spacing: AppSpacing.large) {
                        introCard

                        ForEach(Array(document.sections.enumerated()), id: \.element.id) { index, section in
                            LegalSectionCardView(
                                number: index + 1,
                                accentColor: document.accentColor,
                                title: section.title,
                                content: section.content
                            )
                        }
                    }
                    .padding(AppSpacing.large)
                    .padding(.bottom, AppSpacing.xxxLarge)
                }
            }
        }
    }
}

// MARK: - Subviews

private extension LegalDocumentView {

    var introCard: some View {
        LegalIntroCardView(
            icon: document.icon,
            accentColor: document.accentColor,
            title: document.title,
            subtitle: document.updatedAt,
            description: document.intro
        )
    }
}

#Preview("Политика") {
    LegalDocumentView(document: .privacyPolicy)
}

#Preview("Условия") {
    LegalDocumentView(document: .termsOfService)
}

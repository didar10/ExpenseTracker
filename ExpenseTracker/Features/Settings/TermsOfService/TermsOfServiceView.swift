//
//  TermsOfServiceView.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI

struct TermsOfServiceView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                SheetHeaderView(title: AppString.termsOfService) {
                    dismiss()
                }

                ScrollView {
                    VStack(spacing: AppSpacing.large) {
                        introCard

                        ForEach(Array(TermsOfServiceSection.all.enumerated()), id: \.element.id) { index, section in
                            LegalSectionCardView(
                                number: index + 1,
                                accentColor: AppColor.expense,
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

private extension TermsOfServiceView {

    var introCard: some View {
        LegalIntroCardView(
            icon: AppImage.docText,
            accentColor: AppColor.expense,
            title: AppString.termsOfService,
            subtitle: AppString.lastUpdated,
            description: AppString.termsIntro
        )
    }
}

// MARK: - Terms of Service Section

struct TermsOfServiceSection: Identifiable {
    let id = UUID()
    let title: String
    let content: String

    static let all: [TermsOfServiceSection] = [
        TermsOfServiceSection(title: AppString.termsSection1Title, content: AppString.termsSection1Content),
        TermsOfServiceSection(title: AppString.termsSection2Title, content: AppString.termsSection2Content),
        TermsOfServiceSection(title: AppString.termsSection3Title, content: AppString.termsSection3Content),
        TermsOfServiceSection(title: AppString.termsSection4Title, content: AppString.termsSection4Content),
        TermsOfServiceSection(title: AppString.termsSection5Title, content: AppString.termsSection5Content),
        TermsOfServiceSection(title: AppString.termsSection6Title, content: AppString.termsSection6Content),
        TermsOfServiceSection(title: AppString.termsSection7Title, content: AppString.termsSection7Content),
        TermsOfServiceSection(title: AppString.termsSection8Title, content: AppString.termsSection8Content)
    ]
}

#Preview {
    TermsOfServiceView()
}

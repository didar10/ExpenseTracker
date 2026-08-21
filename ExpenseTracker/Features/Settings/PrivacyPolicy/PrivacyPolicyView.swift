//
//  PrivacyPolicyView.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI

struct PrivacyPolicyView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                SheetHeaderView(title: AppString.privacyPolicyShort) {
                    dismiss()
                }

                ScrollView {
                    VStack(spacing: AppSpacing.large) {
                        introCard

                        ForEach(Array(PrivacyPolicySection.all.enumerated()), id: \.element.id) { index, section in
                            LegalSectionCardView(
                                number: index + 1,
                                accentColor: AppColor.decorativePurple,
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

private extension PrivacyPolicyView {

    var introCard: some View {
        LegalIntroCardView(
            icon: AppImage.handRaised,
            accentColor: AppColor.decorativePurple,
            title: AppString.privacyPolicy,
            subtitle: AppString.lastUpdated
        )
    }
}

// MARK: - Privacy Policy Section

struct PrivacyPolicySection: Identifiable {
    let id = UUID()
    let title: String
    let content: String

    static let all: [PrivacyPolicySection] = [
        PrivacyPolicySection(title: AppString.privacySection1Title, content: AppString.privacySection1Content),
        PrivacyPolicySection(title: AppString.privacySection2Title, content: AppString.privacySection2Content),
        PrivacyPolicySection(title: AppString.privacySection3Title, content: AppString.privacySection3Content),
        PrivacyPolicySection(title: AppString.privacySection4Title, content: AppString.privacySection4Content),
        PrivacyPolicySection(title: AppString.privacySection5Title, content: AppString.privacySection5Content),
        PrivacyPolicySection(title: AppString.privacySection6Title, content: AppString.privacySection6Content)
    ]
}

#Preview {
    PrivacyPolicyView()
}

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
    @Environment(\.tabBarVisibility) private var isTabBarVisible

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xxLarge) {
                    headerSection

                    Divider()

                    ForEach(TermsOfServiceSection.all) { section in
                        TermsSectionView(title: section.title, content: section.content)
                    }
                }
                .padding(AppSpacing.large)
                .padding(.bottom, AppSpacing.xxxLarge)
            }
        }
        .navigationTitle(AppString.termsOfService)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                ToolbarIconButton(icon: "chevron.left") {
                    isTabBarVisible.wrappedValue = true
                    dismiss()
                }
            }
        }
        .onAppear {
            isTabBarVisible.wrappedValue = false
        }
    }
}

// MARK: - Subviews

private extension TermsOfServiceView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            AppText(AppString.termsOfService, style: .largeTitle)

            AppText(AppString.lastUpdated, style: .caption, color: AppColor.textSecondary)

            AppText(AppString.termsIntro, style: .body, color: AppColor.textSecondary)
        }
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

// MARK: - Terms Section View

struct TermsSectionView: View {

    // MARK: - Properties

    let title: String
    let content: String

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            AppText(title, style: .title)

            AppText(content, style: .body, color: AppColor.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        TermsOfServiceView()
    }
}

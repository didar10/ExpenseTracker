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

                    ForEach(PrivacyPolicySection.all) { section in
                        PolicySectionView(title: section.title, content: section.content)
                    }
                }
                .padding(AppSpacing.large)
                .padding(.bottom, AppSpacing.xxxLarge)
            }
        }
        .navigationTitle(AppString.privacyPolicyShort)
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

private extension PrivacyPolicyView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            AppText(AppString.privacyPolicy, style: .largeTitle)

            AppText(AppString.lastUpdated, style: .caption, color: AppColor.textSecondary)
        }
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

// MARK: - Policy Section View

struct PolicySectionView: View {

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
        PrivacyPolicyView()
    }
}

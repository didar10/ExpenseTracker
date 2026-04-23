//
//  SettingsView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI

struct SettingsView: View {

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppText(AppString.settings, style: .title)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, AppSpacing.large)
                    .background(AppColor.background)

                ScrollView {
                    VStack(spacing: AppSpacing.xLarge) {
                        generalSection
                        informationSection
                        appInfoSection
                    }
                    .padding(AppSpacing.large)
                    .padding(.bottom, AppSpacing.tabBarBottomInset)
                }
            }
            .background(AppColor.background)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Subviews

private extension SettingsView {

    var generalSection: some View {
        VStack(spacing: AppSpacing.medium) {
            AppText(AppString.general, style: .sectionHeader, color: AppColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpacing.xSmall)

            VStack(spacing: 0) {
                SettingsRowView(
                    icon: AppImage.categoriesGrid,
                    iconColor: AppColor.accent,
                    title: AppString.categories,
                    destination: CategoriesListView()
                )

                Divider()
                    .padding(.leading, AppSpacing.listDividerIndent)

                SettingsRowView(
                    icon: AppImage.dollarsignCircle,
                    iconColor: AppColor.income,
                    title: AppString.defaultCurrency,
                    destination: PlansView()
                )
            }
            .cardShadow(cornerRadius: AppRadius.card)
        }
    }

    var informationSection: some View {
        VStack(spacing: AppSpacing.medium) {
            AppText(AppString.information, style: .sectionHeader, color: AppColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpacing.xSmall)

            VStack(spacing: 0) {
                SettingsRowView(
                    icon: AppImage.handRaised,
                    iconColor: AppColor.decorativePurple,
                    title: AppString.privacyPolicy,
                    destination: PrivacyPolicyView()
                )

                Divider()
                    .padding(.leading, AppSpacing.listDividerIndent)

                SettingsRowView(
                    icon: AppImage.questionmarkCircle,
                    iconColor: AppColor.warning,
                    title: AppString.helpAndSupport,
                    destination: HelpSupportView()
                )

                Divider()
                    .padding(.leading, AppSpacing.listDividerIndent)

                SettingsRowView(
                    icon: AppImage.docText,
                    iconColor: AppColor.expense,
                    title: AppString.termsOfService,
                    destination: TermsOfServiceView()
                )
            }
            .cardShadow(cornerRadius: AppRadius.card)
        }
    }

    var appInfoSection: some View {
        VStack(spacing: AppSpacing.small) {
            AppText(AppString.appName, style: .sectionHeader, color: AppColor.textSecondary)
            AppText(AppString.appVersion, style: .caption, color: AppColor.textSecondary)
        }
        .padding(.top, AppSpacing.xLarge)
    }
}

// MARK: - Settings Row View

struct SettingsRowView<Destination: View>: View {

    // MARK: - Properties

    let icon: Image
    let iconColor: Color
    let title: String
    let destination: Destination

    // MARK: - Body

    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: AppSpacing.large) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)

                    icon
                        .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                        .foregroundStyle(iconColor)
                }
                .circleShadow()

                AppText(title, style: .bodySmaller)

                Spacer()

                AppImage.chevronRight
                    .font(.system(size: AppSize.glyphMedium, weight: .semibold))
                    .foregroundStyle(AppColor.textTertiary)
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.vertical, AppSpacing.medium)
            .contentShape(Rectangle())
        }
        .buttonStyle(SettingsButtonStyle())
    }
}

struct SettingsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? AppColor.secondaryBackground : Color.clear)
    }
}

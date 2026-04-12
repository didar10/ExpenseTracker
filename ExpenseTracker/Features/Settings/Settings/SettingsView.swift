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
                    .padding(.vertical, 16)
                    .background(AppColor.background)

                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: - General
                        VStack(spacing: 12) {
                            AppText(AppString.general, style: .sectionHeader, color: AppColor.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)

                            VStack(spacing: 0) {
                                SettingsRowView(
                                    icon: "square.grid.2x2",
                                    iconColor: AppColor.accent,
                                    title: AppString.categories,
                                    destination: CategoriesListView()
                                )

                                Divider()
                                    .padding(.leading, 60)

                                SettingsRowView(
                                    icon: "dollarsign.circle",
                                    iconColor: AppColor.income,
                                    title: AppString.defaultCurrency,
                                    destination: PlansView()
                                )
                            }
                            .cardShadow(cornerRadius: 16)
                        }

                        // MARK: - Information
                        VStack(spacing: 12) {
                            AppText(AppString.information, style: .sectionHeader, color: AppColor.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)

                            VStack(spacing: 0) {
                                SettingsRowView(
                                    icon: "hand.raised.fill",
                                    iconColor: .purple,
                                    title: AppString.privacyPolicy,
                                    destination: PrivacyPolicyView()
                                )

                                Divider()
                                    .padding(.leading, 60)

                                SettingsRowView(
                                    icon: "questionmark.circle",
                                    iconColor: AppColor.warning,
                                    title: AppString.helpAndSupport,
                                    destination: HelpSupportView()
                                )

                                Divider()
                                    .padding(.leading, 60)

                                SettingsRowView(
                                    icon: "doc.text",
                                    iconColor: AppColor.expense,
                                    title: AppString.termsOfService,
                                    destination: TermsOfServiceView()
                                )
                            }
                            .cardShadow(cornerRadius: 16)
                        }

                        // MARK: - App Info
                        VStack(spacing: 8) {
                            AppText("ExpenseTracker", style: .sectionHeader, color: AppColor.textSecondary)
                            AppText(AppString.appVersion, style: .caption, color: AppColor.textSecondary)
                        }
                        .padding(.top, 20)
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
            }
            .background(AppColor.background)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Settings Row View
struct SettingsRowView<Destination: View>: View {

    // MARK: - Properties

    let icon: String
    let iconColor: Color
    let title: String
    let destination: Destination

    // MARK: - Body

    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 38, height: 38)

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(iconColor)
                }
                .circleShadow()

                AppText(title, style: .bodySmaller)

                Spacer()

                AppImage.chevronRight
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(SettingsButtonStyle())
    }
}

struct SettingsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color(.systemGray5) : Color.clear)
    }
}

//
//  HelpSupportView.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI

struct HelpSupportView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var expandedFAQ: UUID?

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                SheetHeaderView(title: AppString.helpShort) {
                    dismiss()
                }

                ScrollView {
                    VStack(spacing: AppSpacing.xLarge) {
                        introCard
                        contactsSection
                        faqSection
                        contactCard
                    }
                    .padding(AppSpacing.large)
                    .padding(.bottom, AppSpacing.xxxLarge)
                }
            }
        }
    }
}

// MARK: - Subviews

private extension HelpSupportView {

    var introCard: some View {
        AppCardView {
            VStack(spacing: AppSpacing.large) {
                AppImage.helpCircle
                    .font(.system(size: AppSize.glyphEmptyState))
                    .foregroundStyle(AppColor.accent)
                    .symbolRenderingMode(.hierarchical)

                VStack(spacing: AppSpacing.small) {
                    AppText(AppString.helpAndSupport, style: .section)

                    AppText(
                        AppString.helpSupportIntro,
                        style: .bodySmaller,
                        color: AppColor.textSecondary,
                        alignment: .center
                    )
                }
            }
            .padding(.vertical, AppSpacing.medium)
            .frame(maxWidth: .infinity)
        }
        .accessibilityElement(children: .combine)
    }

    var contactsSection: some View {
        VStack(spacing: AppSpacing.medium) {
            sectionHeader(AppString.quickActions)

            AppCardView {
                VStack(spacing: 0) {
                    ForEach(Array(SupportContact.all.enumerated()), id: \.element.id) { index, contact in
                        SupportContactRow(contact: contact)

                        if index < SupportContact.all.count - 1 {
                            Divider()
                                .padding(.leading, AppSize.iconLarge + AppSpacing.medium)
                        }
                    }
                }
            }
        }
    }

    var faqSection: some View {
        VStack(spacing: AppSpacing.medium) {
            sectionHeader(AppString.faq)

            VStack(spacing: AppSpacing.medium) {
                ForEach(FAQItem.all) { item in
                    FAQItemView(item: item, isExpanded: expandedFAQ == item.id) {
                        toggle(item)
                    }
                }
            }
        }
    }

    var contactCard: some View {
        AppCardView {
            VStack(spacing: AppSpacing.large) {
                AppText(AppString.noAnswerFound, style: .section)

                AppText(
                    AppString.supportAvailable,
                    style: .bodySmaller,
                    color: AppColor.textSecondary,
                    alignment: .center
                )

                Button(action: writeToSupport) {
                    HStack(spacing: AppSpacing.small) {
                        AppImage.envelope
                            .font(.system(size: AppSize.glyphMedium, weight: .semibold))

                        AppText(AppString.contactSupport, style: .bodySmall, color: AppColor.background)
                    }
                    .foregroundStyle(AppColor.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.large)
                    .background(
                        Capsule(style: .continuous)
                            .fill(AppColor.textPrimary)
                    )
                }
                .buttonStyle(PressableScaleButtonStyle())
            }
            .padding(.vertical, AppSpacing.small)
            .frame(maxWidth: .infinity)
        }
    }

    func sectionHeader(_ title: String) -> some View {
        AppText(title, style: .sectionHeader, color: AppColor.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppSpacing.xSmall)
    }
}

// MARK: - Actions

private extension HelpSupportView {

    func toggle(_ item: FAQItem) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            expandedFAQ = expandedFAQ == item.id ? nil : item.id
        }
    }

    func writeToSupport() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        guard let url = SupportContact.email.url else { return }

        openURL(url) { accepted in
            guard !accepted else { return }

            UIPasteboard.general.string = SupportContact.email.value
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }
}

#Preview {
    HelpSupportView()
}

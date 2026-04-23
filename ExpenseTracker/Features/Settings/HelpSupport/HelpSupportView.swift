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
    @Environment(\.tabBarVisibility) private var isTabBarVisible
    @State private var expandedFAQ: UUID?

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.xxLarge) {
                    introSection
                    quickActionsSection
                    faqSection
                    contactSection
                }
                .padding(AppSpacing.large)
                .padding(.bottom, AppSpacing.xxxLarge)
            }
        }
        .navigationTitle(AppString.helpShort)
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

private extension HelpSupportView {

    var introSection: some View {
        VStack(spacing: AppSpacing.medium) {
            AppImage.helpCircle
                .font(.system(size: AppSize.glyphHuge))
                .foregroundStyle(AppColor.accent.gradient)

            AppText(AppString.helpAndSupport, style: .largeTitle)

            AppText(
                AppString.helpSupportIntro,
                style: .body,
                color: AppColor.textSecondary,
                alignment: .center
            )
            .padding(.horizontal, AppSpacing.large)
        }
        .padding(.top, AppSpacing.xLarge)
    }

    var quickActionsSection: some View {
        VStack(spacing: AppSpacing.medium) {
            AppText(AppString.quickActions, style: .section)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 0) {
                QuickActionRow(
                    icon: AppImage.envelope,
                    iconColor: AppColor.accent,
                    title: AppString.writeToUs,
                    subtitle: AppString.supportEmail
                )

                Divider()
                    .padding(.leading, AppSpacing.listDividerIndent)

                QuickActionRow(
                    icon: AppImage.globe,
                    iconColor: AppColor.income,
                    title: AppString.website,
                    subtitle: AppString.supportWebsite
                )

                Divider()
                    .padding(.leading, AppSpacing.listDividerIndent)

                QuickActionRow(
                    icon: AppImage.message,
                    iconColor: AppColor.decorativePurple,
                    title: AppString.telegram,
                    subtitle: AppString.supportTelegram
                )
            }
            .cardShadow(cornerRadius: AppRadius.card)
        }
    }

    var faqSection: some View {
        VStack(spacing: AppSpacing.medium) {
            AppText(AppString.faq, style: .section)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: AppSpacing.small) {
                ForEach(FAQItem.all) { item in
                    FAQItemView(
                        item: item,
                        isExpanded: expandedFAQ == item.id
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            expandedFAQ = expandedFAQ == item.id ? nil : item.id
                        }
                    }
                }
            }
        }
    }

    var contactSection: some View {
        VStack(spacing: AppSpacing.large) {
            AppText(AppString.noAnswerFound, style: .title)

            AppText(
                AppString.supportAvailable,
                style: .body,
                color: AppColor.textSecondary,
                alignment: .center
            )

            Button {
                // TODO: open mail composer
            } label: {
                HStack {
                    AppImage.envelope
                    AppText(AppString.contactSupport, style: .bodySmall)
                }
                .foregroundStyle(AppColor.textWhite)
                .frame(maxWidth: .infinity)
                .padding(AppSpacing.large)
                .background(AppColor.accent.gradient)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.button))
            }
        }
        .padding(.vertical, AppSpacing.xLarge)
    }
}

// MARK: - FAQ Item

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String

    static let all: [FAQItem] = [
        FAQItem(question: AppString.faqQ1, answer: AppString.faqA1),
        FAQItem(question: AppString.faqQ2, answer: AppString.faqA2),
        FAQItem(question: AppString.faqQ3, answer: AppString.faqA3),
        FAQItem(question: AppString.faqQ4, answer: AppString.faqA4),
        FAQItem(question: AppString.faqQ5, answer: AppString.faqA5),
        FAQItem(question: AppString.faqQ6, answer: AppString.faqA6),
        FAQItem(question: AppString.faqQ7, answer: AppString.faqA7),
        FAQItem(question: AppString.faqQ8, answer: AppString.faqA8)
    ]
}

// MARK: - Quick Action Row

struct QuickActionRow: View {

    // MARK: - Properties

    let icon: Image
    let iconColor: Color
    let title: String
    let subtitle: String

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.large) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: AppSize.iconLarge, height: AppSize.iconLarge)

                icon
                    .font(.system(size: AppSize.glyphXLarge, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                AppText(title, style: .body)

                AppText(subtitle, style: .caption, color: AppColor.textSecondary)
            }

            Spacer()

            AppImage.arrowUpRight
                .font(.system(size: AppSize.glyphMedium, weight: .semibold))
                .foregroundStyle(AppColor.textTertiary)
        }
        .padding(AppSpacing.large)
    }
}

// MARK: - FAQ Item View

struct FAQItemView: View {

    // MARK: - Properties

    let item: FAQItem
    let isExpanded: Bool
    let onTap: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack {
                    AppText(item.question, style: .body)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()

                    expandIcon
                }
                .padding(AppSpacing.large)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()

                AppText(item.answer, style: .bodySmaller, color: AppColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(AppSpacing.large)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large))
        .shadow(color: AppColor.textPrimary.opacity(0.05), radius: AppSpacing.xSmall, y: AppSpacing.xxSmall)
    }

    private var expandIcon: some View {
        Group {
            if isExpanded {
                AppImage.chevronUp
            } else {
                AppImage.chevronDown
            }
        }
        .font(.system(size: AppSize.glyphMedium, weight: .semibold))
        .foregroundStyle(AppColor.textSecondary)
    }
}

#Preview {
    NavigationStack {
        HelpSupportView()
    }
}

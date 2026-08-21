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
                        quickActionsSection
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
                    .foregroundStyle(AppColor.accent.gradient)

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
    }

    var quickActionsSection: some View {
        VStack(spacing: AppSpacing.medium) {
            sectionHeader(AppString.quickActions)

            AppCardView {
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
            }
        }
    }

    var faqSection: some View {
        VStack(spacing: AppSpacing.medium) {
            sectionHeader(AppString.faq)

            VStack(spacing: AppSpacing.medium) {
                ForEach(FAQItem.all) { item in
                    FAQItemView(
                        item: item,
                        isExpanded: expandedFAQ == item.id
                    ) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            expandedFAQ = expandedFAQ == item.id ? nil : item.id
                        }
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

                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    // TODO: open mail composer
                } label: {
                    HStack(spacing: AppSpacing.small) {
                        AppImage.envelope
                            .font(.system(size: AppSize.glyphMedium, weight: .semibold))

                        AppText(AppString.contactSupport, style: .bodySmall)
                    }
                    .foregroundStyle(AppColor.textWhite)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.large)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                            .fill(AppColor.accent.gradient)
                    )
                }
                .buttonStyle(.plain)
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
        HStack(spacing: AppSpacing.medium) {
            iconBadge

            VStack(alignment: .leading, spacing: AppSpacing.xxSmall) {
                AppText(title, style: .bodySmall)

                AppText(subtitle, style: .caption, color: AppColor.textSecondary)
            }

            Spacer()

            AppImage.arrowUpRight
                .font(.system(size: AppSize.glyphMedium, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, AppSpacing.small)
        .contentShape(Rectangle())
    }

    // MARK: - Subviews

    private var iconBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .fill(iconColor.opacity(0.2))
                .frame(width: AppSize.iconLarge, height: AppSize.iconLarge)

            icon
                .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                .foregroundStyle(iconColor)
        }
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
                HStack(spacing: AppSpacing.medium) {
                    AppText(item.question, style: .bodySmall)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    expandIcon
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                    .padding(.vertical, AppSpacing.medium)

                AppText(item.answer, style: .bodySmaller, color: AppColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(AppSpacing.large)
        .card(cornerRadius: AppRadius.xLarge)
    }

    // MARK: - Subviews

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
        .frame(width: AppSize.iconSmall, height: AppSize.iconSmall)
        .background(
            Circle()
                .fill(AppColor.secondaryBackground)
        )
    }
}

#Preview {
    HelpSupportView()
}

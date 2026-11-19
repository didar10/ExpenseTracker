//
//  SupportContactRow.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI

/// Строка контакта поддержки: нажатие открывает почту, сайт или Telegram,
/// долгое нажатие дает скопировать адрес — на случай, когда открывать нечем
struct SupportContactRow: View {

    // MARK: - Properties

    let contact: SupportContact

    @Environment(\.openURL) private var openURL

    // MARK: - Body

    var body: some View {
        Button(action: open) {
            label
        }
        .buttonStyle(HighlightRowButtonStyle(cornerRadius: AppRadius.medium))
        .contextMenu {
            Button {
                UIPasteboard.general.string = contact.value
            } label: {
                Label(AppString.copy, systemImage: "doc.on.doc")
            }
        }
        .accessibilityLabel(contact.title)
        .accessibilityValue(contact.value)
        .accessibilityAddTraits(.isLink)
    }
}

// MARK: - Subviews
private extension SupportContactRow {

    var label: some View {
        HStack(spacing: AppSpacing.medium) {
            iconBadge

            VStack(alignment: .leading, spacing: AppSpacing.xxSmall) {
                AppText(contact.title, style: .bodySmall)

                AppText(contact.value, style: .caption, color: AppColor.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer(minLength: AppSpacing.small)

            AppImage.arrowUpRight
                .font(.system(size: AppSize.glyphMedium, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, AppSpacing.small)
        .contentShape(Rectangle())
    }

    var iconBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .fill(contact.iconColor.opacity(0.2))
                .frame(width: AppSize.iconLarge, height: AppSize.iconLarge)

            contact.icon
                .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                .foregroundStyle(contact.iconColor)
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Actions
private extension SupportContactRow {

    func open() {
        guard let url = contact.url else { return }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // Открыть почту или Telegram может быть нечем: тогда адрес хотя бы
        // остается в буфере обмена, а не пропадает вместе с нажатием
        openURL(url) { accepted in
            guard !accepted else { return }

            UIPasteboard.general.string = contact.value
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }
}

#Preview {
    AppCardView {
        VStack(spacing: 0) {
            SupportContactRow(contact: .email)

            Divider()
                .padding(.leading, AppSize.iconLarge + AppSpacing.medium)

            SupportContactRow(contact: .telegram)
        }
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

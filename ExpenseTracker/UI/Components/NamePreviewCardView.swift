//
//  NamePreviewCardView.swift
//  ExpenseTracker
//
//  Created by Didar on 23.08.2026.
//

import SwiftUI

/// Превью создаваемой сущности: иконка в круге и поле ввода названия внутри капсулы
struct NamePreviewCardView: View {

    // MARK: - Properties

    @Binding var name: String
    let icon: String
    let color: Color
    let placeholder: String

    // MARK: - Body

    var body: some View {
        // Капсула прижимается к содержимому, пока оно помещается на экран,
        // а для длинных названий переходит на всю доступную ширину
        ViewThatFits(in: .horizontal) {
            previewPill
                .fixedSize(horizontal: true, vertical: false)

            previewPill
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Subviews
private extension NamePreviewCardView {

    var previewPill: some View {
        HStack(spacing: AppSpacing.small) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)

                Image(systemName: icon)
                    .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
            }

            TextField(
                "",
                text: $name,
                prompt: Text(placeholder)
                    .font(.app(.bodySmall))
                    .foregroundColor(AppColor.textPrimary.opacity(0.6))
            )
            .font(.app(.bodySmall))
            .foregroundStyle(AppColor.textPrimary)
            .tint(AppColor.textPrimary)
            .lineLimit(1)
        }
        .padding(.leading, AppSpacing.xSmall)
        .padding(.trailing, AppSpacing.xLarge)
        .padding(.vertical, AppSpacing.xSmall)
        .background(
            Capsule(style: .continuous)
                .fill(AppColor.fieldFill)
        )
    }
}

#Preview {
    VStack(spacing: AppSpacing.large) {
        NamePreviewCardView(
            name: .constant("Основной счёт"),
            icon: "creditcard.fill",
            color: Color(named: "blue"),
            placeholder: AppString.accountName
        )

        NamePreviewCardView(
            name: .constant(""),
            icon: "cart.fill",
            color: Color(hex: "#F5A623"),
            placeholder: AppString.categoryName
        )

        NamePreviewCardView(
            name: .constant("Очень длинное название категории, которое не помещается"),
            icon: "cart.fill",
            color: Color(hex: "#4CAF50"),
            placeholder: AppString.categoryName
        )
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

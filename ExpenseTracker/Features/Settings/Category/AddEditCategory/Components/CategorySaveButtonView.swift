//
//  CategorySaveButtonView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

struct CategorySaveButtonView: View {

    // MARK: - Properties

    let title: String
    let isEnabled: Bool
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack {
                AppImage.checkmarkCircleFill
                    .font(.system(size: AppSize.glyphXLarge))

                AppText(title, style: .section)
            }
            .foregroundStyle(AppColor.textWhite)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.large)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .fill(isEnabled ? AppColor.income : AppColor.textTertiary)
            )
            .shadow(
                color: isEnabled ? AppColor.income.opacity(0.3) : Color.clear,
                radius: AppSpacing.small,
                y: AppSpacing.xSmall
            )
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
        .padding(.top, AppSpacing.small)
    }
}

#Preview {
    VStack(spacing: AppSpacing.large) {
        CategorySaveButtonView(title: AppString.createCategory, isEnabled: true, action: {})
        CategorySaveButtonView(title: AppString.createCategory, isEnabled: false, action: {})
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

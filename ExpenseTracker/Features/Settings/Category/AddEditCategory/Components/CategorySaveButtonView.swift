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
                    .font(.system(size: 20))

                AppText(title, style: .section)
            }
            .foregroundStyle(AppColor.textWhite)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isEnabled ? AppColor.income : AppColor.textTertiary)
            )
            .shadow(
                color: isEnabled ? AppColor.income.opacity(0.3) : Color.clear,
                radius: 8,
                y: 4
            )
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
        .padding(.top, 8)
    }
}

#Preview {
    VStack(spacing: 16) {
        CategorySaveButtonView(title: AppString.createCategory, isEnabled: true, action: {})
        CategorySaveButtonView(title: AppString.createCategory, isEnabled: false, action: {})
    }
    .padding()
    .background(AppColor.background)
}

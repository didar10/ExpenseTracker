//
//  CategoryPreviewCardView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

struct CategoryPreviewCardView: View {

    // MARK: - Properties

    let name: String
    let icon: String
    let colorHex: String

    // MARK: - Body

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            ZStack {
                Circle()
                    .fill(Color(hex: colorHex).opacity(0.15))
                    .frame(width: AppSize.iconHuge, height: AppSize.iconHuge)

                Image(systemName: icon)
                    .font(.system(size: AppSize.iconLarge, weight: .semibold))
                    .foregroundStyle(Color(hex: colorHex))
            }

            Text(name.isEmpty ? AppString.categoryName : name)
                .font(.app(.title))
                .foregroundStyle(name.isEmpty ? AppColor.textSecondary : AppColor.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xxxLarge)
        .card(cornerRadius: AppRadius.xLarge)
    }
}

#Preview {
    VStack {
        CategoryPreviewCardView(name: "Продукты", icon: "cart.fill", colorHex: "#FF6B6B")
        CategoryPreviewCardView(name: "", icon: "cart.fill", colorHex: "#34C759")
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

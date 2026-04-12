//
//  PlansEmptyStateView.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI

struct PlansEmptyStateView: View {

    // MARK: - Properties

    let onCreateTap: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            AppImage.chartBarDoc
                .font(.system(size: 70))
                .foregroundStyle(AppColor.accent.opacity(0.7))
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: 10) {
                AppText(AppString.noBudgets, style: .title)

                AppText(AppString.noBudgetsHint, style: .body, color: AppColor.textSecondary, alignment: .center)
                    .padding(.horizontal, 40)
            }

            Button(action: onCreateTap) {
                HStack(spacing: 8) {
                    AppImage.plusCircleFill
                        .font(.system(size: 18))
                    AppText(AppString.createBudget, style: .section)
                }
                .foregroundStyle(AppColor.textWhite)
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .background(AppColor.accent)
                .clipShape(Capsule())
                .shadow(color: AppColor.accent.opacity(0.3), radius: 8, y: 4)
            }
            .padding(.top, 8)

            Spacer()
        }
    }
}

#Preview {
    PlansEmptyStateView(onCreateTap: {})
        .background(AppColor.background)
}

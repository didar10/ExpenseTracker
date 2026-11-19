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
        AppCardView {
            VStack(spacing: AppSpacing.large) {
                AppImage.chartBarDoc
                    .font(.system(size: AppSize.glyphEmptyState))
                    .foregroundStyle(.tertiary)
                    .symbolRenderingMode(.hierarchical)

                VStack(spacing: AppSpacing.small) {
                    AppText(AppString.noBudgets, style: .section)

                    AppText(
                        AppString.noBudgetsHint,
                        style: .bodySmaller,
                        color: AppColor.textSecondary,
                        alignment: .center
                    )
                }

                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onCreateTap()
                } label: {
                    HStack(spacing: AppSpacing.small) {
                        AppImage.plus
                            .font(.system(size: AppSize.glyphLarge, weight: .semibold))

                        AppText(AppString.createBudget, style: .bodySmall, color: AppColor.background)
                    }
                    .foregroundStyle(AppColor.background)
                    .padding(.horizontal, AppSpacing.xLarge)
                    .padding(.vertical, AppSpacing.medium)
                    .background(
                        Capsule(style: .continuous)
                            .fill(AppColor.textPrimary)
                    )
                }
                .buttonStyle(.plain)
                .padding(.top, AppSpacing.small)
            }
            .padding(.vertical, AppSpacing.xxLarge)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    PlansEmptyStateView(onCreateTap: {})
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

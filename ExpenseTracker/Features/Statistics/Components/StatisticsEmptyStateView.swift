//
//  StatisticsEmptyStateView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Пустое состояние для экрана статистики
struct StatisticsEmptyStateView: View {

    // MARK: - Body

    var body: some View {
        VStack(spacing: AppSpacing.medium) {
            AppImage.chartPie
                .font(.system(size: AppSize.glyphEmptyState))
                .foregroundStyle(AppColor.textTertiary)
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: AppSpacing.smaller) {
                AppText(AppString.noData, style: .section)

                AppText(
                    AppString.noDataHint,
                    style: .sectionHeader,
                    color: AppColor.textSecondary,
                    alignment: .center
                )
            }
        }
        .padding(.vertical, AppSpacing.xxxLarge)
    }
}

#Preview {
    StatisticsEmptyStateView()
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

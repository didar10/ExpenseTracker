//
//  StatisticsEmptyStateView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Текстовая часть пустого состояния статистики —
/// располагается под переключателем периода
struct StatisticsEmptyStateView: View {

    // MARK: - Properties

    let hint: String

    // MARK: - Body

    var body: some View {
        VStack(spacing: AppSpacing.smaller) {
            AppText(AppString.noData, style: .section)

            AppText(
                hint,
                style: .sectionHeader,
                color: AppColor.textSecondary,
                alignment: .center
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.small)
    }
}

#Preview {
    StatisticsEmptyStateView(hint: AppString.noDataHint)
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

//
//  StatisticsEmptyStateView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Текстовая часть пустого состояния статистики — стоит в центре пустой диаграммы
struct StatisticsEmptyStateView: View {

    // MARK: - Properties

    let hint: String

    // MARK: - Body

    var body: some View {
        VStack(spacing: AppSpacing.smaller) {
            AppText(AppString.noData, style: .section, alignment: .center)

            AppText(
                hint,
                style: .sectionHeader,
                color: AppColor.textSecondary,
                alignment: .center
            )
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    StatisticsEmptyStateView(hint: AppString.noDataHint)
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

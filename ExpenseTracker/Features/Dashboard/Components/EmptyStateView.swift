//
//  EmptyStateView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

struct EmptyStateView: View {

    // MARK: - Properties

    var hint: String = AppString.noTransactionsHint
    /// Задан, когда список пуст из-за фильтра периода: предлагаем его сбросить
    var resetAction: (() -> Void)?

    // MARK: - Body

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            AppImage.emptyState
                .font(.system(size: AppSize.glyphEmptyState))
                .foregroundStyle(AppColor.textTertiary)

            VStack(spacing: AppSpacing.small) {
                AppText(AppString.noTransactions, style: .title)

                AppText(hint, style: .bodySmall, color: AppColor.textSecondary, alignment: .center)
            }

            if let resetAction {
                PillActionButton(title: AppString.periodAllTime, action: resetAction)
            }
        }
        .padding(.horizontal, AppSpacing.xLarge)
        .padding(.vertical, AppSpacing.huge)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
    }
}

#Preview("Нет операций") {
    EmptyStateView()
        .background(AppColor.background)
}

#Preview("Пусто за период") {
    EmptyStateView(
        hint: AppString.noTransactionsInPeriod("Август"),
        resetAction: {}
    )
    .background(AppColor.background)
}

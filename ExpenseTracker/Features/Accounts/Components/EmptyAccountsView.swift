//
//  EmptyAccountsView.swift
//  ExpenseTracker
//
//  Created by Didar on 02.09.2026.
//

import SwiftUI

/// Пустой список счетов: объясняет, зачем нужен счет, и даёт создать его прямо отсюда
struct EmptyAccountsView: View {

    // MARK: - Properties

    let onAddTap: () -> Void

    // MARK: - Body

    var body: some View {
        AppCardView {
            VStack(spacing: AppSpacing.large) {
                AppImage.noAccountsIcon
                    .font(.system(size: AppSize.glyphEmptyState))
                    .foregroundStyle(.tertiary)
                    .symbolRenderingMode(.hierarchical)

                VStack(spacing: AppSpacing.small) {
                    AppText(AppString.noAccounts, style: .section)

                    AppText(
                        AppString.addAccountHint,
                        style: .bodySmaller,
                        color: AppColor.textSecondary,
                        alignment: .center
                    )
                }

                PillActionButton(title: AppString.addAccount, action: onAddTap)
                    .padding(.top, AppSpacing.small)
            }
            .padding(.vertical, AppSpacing.xxLarge)
            .frame(maxWidth: .infinity)
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    EmptyAccountsView(onAddTap: {})
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

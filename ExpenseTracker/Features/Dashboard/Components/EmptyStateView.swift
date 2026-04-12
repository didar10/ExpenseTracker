//
//  EmptyStateView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

struct EmptyStateView: View {

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            AppImage.emptyState
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)

            VStack(spacing: 8) {
                AppText(AppString.noTransactions, style: .title)

                AppText(AppString.noTransactionsHint, style: .bodySmall, color: AppColor.textSecondary, alignment: .center)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView()
}

//
//  TransactionsListView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Список операций, сгруппированных по дням. Строки создаются лениво,
/// заголовки дней прилипают к верху при прокрутке
struct TransactionsListView: View {

    // MARK: - Properties

    let sections: [TransactionSection]
    var emptyStateHint: String = AppString.noTransactionsHint
    var isFilteredByPeriod = false
    let onTransactionTap: (Transaction) -> Void
    var onResetPeriod: () -> Void = {}

    // MARK: - Body

    var body: some View {
        LazyVStack(spacing: AppSpacing.small, pinnedViews: [.sectionHeaders]) {
            if sections.isEmpty {
                EmptyStateView(
                    hint: emptyStateHint,
                    resetAction: isFilteredByPeriod ? onResetPeriod : nil
                )
            } else {
                ForEach(sections) { section in
                    Section {
                        ForEach(section.transactions) { transaction in
                            TransactionRowView(transaction: transaction) {
                                onTransactionTap(transaction)
                            }
                        }
                    } header: {
                        SectionHeaderView(date: section.date)
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.large)
    }
}

#Preview {
    ScrollView {
        TransactionsListView(sections: []) { _ in }
    }
    .background(AppColor.background)
}

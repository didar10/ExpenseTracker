//
//  TransactionsListView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Компонент списка транзакций, сгруппированных по датам
struct TransactionsListView: View {
    let sections: [TransactionSection]
    let onTransactionTap: (Transaction) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if sections.isEmpty {
                EmptyStateView()
            } else {
                ForEach(sections) { section in
                    TransactionSectionView(
                        section: section,
                        onTransactionTap: onTransactionTap
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            }
        }
    }
}

#Preview {
    TransactionsListView(sections: []) { _ in }
}

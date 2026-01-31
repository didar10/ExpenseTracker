//
//  TransactionSectionView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Компонент отображения секции транзакций с заголовком даты
struct TransactionSectionView: View {
    let section: TransactionSection
    let onTransactionTap: (Transaction) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeaderView(date: section.date)
                .padding(.bottom, 4)
            
            ForEach(section.transactions) { transaction in
                TransactionRowView(transaction: transaction)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .cardShadow(cornerRadius: 12)
                    .onTapGesture {
                        onTransactionTap(transaction)
                    }
            }
        }
    }
}

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
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(date: section.date)
                .padding(.top, 16)
            
            VStack(spacing: 8) {
                ForEach(section.transactions) { transaction in
                    TransactionRowView(transaction: transaction)
                        .onTapGesture {
                            onTransactionTap(transaction)
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(
                        color: .black.opacity(0.65),
                        radius: 0,
                        x: 4,
                        y: 6
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.15), lineWidth: 1.5)
            )
        }
    }
}

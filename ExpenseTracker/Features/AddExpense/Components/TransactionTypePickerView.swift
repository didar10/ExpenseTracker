//
//  TransactionTypePickerView.swift
//  ExpenseTracker
//
//  Created by Didar on 23.01.2026.
//

import SwiftUI

struct TransactionTypePickerView: View {
    @Binding var selectedType: TransactionType
    
    var body: some View {
        HStack(spacing: 6) {
            // Expense button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedType = .expense
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.orange)
                    if selectedType == .expense {
                        Text("Расход")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.primary)
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(selectedType == .expense ? Color.orange.opacity(0.15) : .clear)
                )
            }
            .buttonStyle(.plain)

            // Income button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedType = .income
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.green)
                    if selectedType == .income {
                        Text("Доход")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.primary)
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(selectedType == .income ? Color.green.opacity(0.15) : .clear)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(6)
        .background(
            Capsule().fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

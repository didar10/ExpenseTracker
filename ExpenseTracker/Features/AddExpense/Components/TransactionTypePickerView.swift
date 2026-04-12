//
//  TransactionTypePickerView.swift
//  ExpenseTracker
//
//  Created by Didar on 23.01.2026.
//

import SwiftUI

struct TransactionTypePickerView: View {

    // MARK: - Properties

    @Binding var selectedType: TransactionType

    // MARK: - Body

    var body: some View {
        HStack(spacing: 6) {
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedType = .expense
                }
            } label: {
                HStack(spacing: 6) {
                    AppImage.expenseDirection
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColor.warning)
                    if selectedType == .expense {
                        AppText(AppString.expense, style: .caption)
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(selectedType == .expense ? AppColor.warning.opacity(0.15) : .clear)
                )
            }
            .buttonStyle(.plain)

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedType = .income
                }
            } label: {
                HStack(spacing: 6) {
                    AppImage.incomeDirection
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColor.income)
                    if selectedType == .income {
                        AppText(AppString.income, style: .caption)
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(selectedType == .income ? AppColor.income.opacity(0.15) : .clear)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(6)
        .background(
            Capsule().fill(AppColor.secondaryBackground)
        )
    }
}

//
//  BudgetPeriodPickerView.swift
//  ExpenseTracker
//
//  Created by Didar on 22.08.2026.
//

import SwiftUI

/// Переключатель периода бюджета
struct BudgetPeriodPickerView: View {

    // MARK: - Properties

    @Binding var selectedPeriod: BudgetPeriod

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.smaller) {
            ForEach(BudgetPeriod.allCases, id: \.self) { period in
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedPeriod = period
                    }
                } label: {
                    AppText(
                        period.rawValue,
                        style: .caption,
                        color: selectedPeriod == period ? AppColor.textPrimary : AppColor.textSecondary,
                        alignment: .center
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.small)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                            .fill(selectedPeriod == period ? AppColor.cardBackground : .clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppSpacing.smaller)
        .background(
            Capsule().fill(AppColor.secondaryBackground)
        )
    }
}

#Preview {
    BudgetPeriodPickerView(selectedPeriod: .constant(.month))
        .padding(AppSpacing.large)
        .background(AppColor.background)
}

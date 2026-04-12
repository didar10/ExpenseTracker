//
//  PeriodPickerButton.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI

struct PeriodPickerButton: View {

    // MARK: - Properties

    let selectedPeriod: BudgetPeriod
    let onPeriodChange: (BudgetPeriod) -> Void

    // MARK: - Body

    var body: some View {
        Menu {
            ForEach(BudgetPeriod.allCases, id: \.self) { period in
                Button {
                    onPeriodChange(period)
                } label: {
                    Label {
                        Text(period.rawValue)
                    } icon: {
                        if selectedPeriod == period {
                            AppImage.checkmark
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                AppImage.calendar
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColor.textPrimary)

                VStack(alignment: .leading, spacing: 1) {
                    Text(AppString.budgets)
                        .font(.app(.caption))
                        .foregroundStyle(AppColor.textPrimary)

                    Text(selectedPeriod.rawValue)
                        .font(.app(.microCaption))
                        .foregroundStyle(AppColor.textSecondary)
                }

                AppImage.chevronDown
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AppColor.textSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(AppColor.cardBackground)
                    .shadow(color: AppColor.textPrimary.opacity(0.04), radius: 4, y: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PeriodPickerButton(selectedPeriod: .month, onPeriodChange: { _ in })
}

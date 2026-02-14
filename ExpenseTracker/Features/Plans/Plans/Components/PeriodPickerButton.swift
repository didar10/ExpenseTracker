//
//  PeriodPickerButton.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI

struct PeriodPickerButton: View {
    let selectedPeriod: BudgetPeriod
    let onPeriodChange: (BudgetPeriod) -> Void
    
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
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.primary)

                VStack(alignment: .leading, spacing: 1) {
                    Text("Бюджеты")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary)

                    Text(selectedPeriod.rawValue)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: Color.primary.opacity(0.04), radius: 4, y: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PeriodPickerButton(
        selectedPeriod: .month,
        onPeriodChange: { _ in }
    )
}

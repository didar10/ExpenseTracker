//
//  MonthPickerView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Компонент для выбора месяца
struct MonthPickerView: View {
    let selectedMonth: Date
    let isNextDisabled: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: handlePreviousTap) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.primary)
                    .symbolRenderingMode(.hierarchical)
            }
            
            Spacer()
            
            Text(monthTitle)
                .font(.app(.section))
                .contentTransition(.numericText())
            
            Spacer()
            
            Button(action: handleNextTap) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.primary)
                    .symbolRenderingMode(.hierarchical)
            }
            .disabled(isNextDisabled)
            .opacity(isNextDisabled ? 0.3 : 1.0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(.systemGroupedBackground))
    }
    
    private var monthTitle: String {
        selectedMonth.formatted(
            Date.FormatStyle()
                .month(.wide)
                .year()
        )
        .capitalized
    }
    
    private func handlePreviousTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onPrevious()
    }
    
    private func handleNextTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onNext()
    }
}

#Preview {
    VStack {
        MonthPickerView(
            selectedMonth: .now,
            isNextDisabled: true,
            onPrevious: {},
            onNext: {}
        )
        
        MonthPickerView(
            selectedMonth: Calendar.current.date(byAdding: .month, value: -1, to: .now)!,
            isNextDisabled: false,
            onPrevious: {},
            onNext: {}
        )
    }
}

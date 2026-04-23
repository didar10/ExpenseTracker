//
//  MonthPickerView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Компонент для выбора месяца
struct MonthPickerView: View {

    // MARK: - Properties

    let selectedMonth: Date
    let isNextDisabled: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.large) {
            Button(action: handlePreviousTap) {
                AppImage.chevronLeftCircleFill
                    .font(.system(size: AppSize.glyphArrow))
                    .foregroundStyle(AppColor.textPrimary)
                    .symbolRenderingMode(.hierarchical)
            }

            Spacer()

            Text(monthTitle)
                .font(.app(.section))
                .contentTransition(.numericText())

            Spacer()

            Button(action: handleNextTap) {
                AppImage.chevronRightCircleFill
                    .font(.system(size: AppSize.glyphArrow))
                    .foregroundStyle(AppColor.textPrimary)
                    .symbolRenderingMode(.hierarchical)
            }
            .disabled(isNextDisabled)
            .opacity(isNextDisabled ? 0.3 : 1.0)
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.large)
        .background(AppColor.background)
    }

    // MARK: - Computed Properties

    private var monthTitle: String {
        selectedMonth.formatted(
            Date.FormatStyle()
                .month(.wide)
                .year()
        )
        .capitalized
    }

    // MARK: - Actions

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

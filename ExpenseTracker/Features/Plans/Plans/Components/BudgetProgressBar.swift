//
//  BudgetProgressBar.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import SwiftUI

/// Полоска бюджета с отметкой «сегодня»: видно, опережают ли траты время.
/// Цвет — по темпу трат, а не по фиксированным порогам
struct BudgetProgressBar: View {

    // MARK: - Properties

    let pace: BudgetPace
    var height: CGFloat = AppSize.progressBar

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppColor.subtleFill)

                Capsule()
                    .fill(pace.level.color)
                    .frame(width: max(geometry.size.width * pace.progress, 0))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: pace)

                if let elapsedFraction = pace.elapsedFraction {
                    todayMarker
                        .offset(x: markerOffset(elapsedFraction, width: geometry.size.width))
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(height: height)
        // Отметка выше полоски — место под нее, чтобы не наезжала на соседние строки
        .padding(.vertical, (AppSize.progressMarkerHeight - height) / 2)
        .accessibilityHidden(true)
    }
}

// MARK: - Subviews

private extension BudgetProgressBar {

    var todayMarker: some View {
        Capsule()
            .fill(AppColor.textPrimary)
            .frame(width: AppSize.progressMarkerWidth, height: AppSize.progressMarkerHeight)
            .overlay(
                Capsule()
                    .stroke(AppColor.cardBackground, lineWidth: AppSize.progressMarkerBorder)
            )
    }

    /// Отметка не выходит за края полоски
    func markerOffset(_ fraction: Double, width: CGFloat) -> CGFloat {
        let x = width * fraction - AppSize.progressMarkerWidth / 2
        return min(max(x, 0), width - AppSize.progressMarkerWidth)
    }
}

// MARK: - Level Color

extension BudgetPace.Level {

    var color: Color {
        switch self {
        case .onTrack: return AppColor.income
        case .ahead: return AppColor.warning
        case .over: return AppColor.expense
        }
    }
}

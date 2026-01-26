//
//  StatisticsEmptyStateView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Пустое состояние для экрана статистики
struct StatisticsEmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: 6) {
                AppText("Нет данных", style: .section)
                
                AppText("Добавьте расходы за выбранный период", style: .sectionHeader, color: .secondary, alignment: .center)
            }
        }
        .padding(.vertical, 32)
    }
}

#Preview {
    StatisticsEmptyStateView()
        .padding()
        .background(Color(.systemGroupedBackground))
}

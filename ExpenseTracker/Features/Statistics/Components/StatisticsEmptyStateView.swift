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
                Text("Нет данных")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Добавьте расходы за выбранный месяц")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
    }
}

#Preview {
    StatisticsEmptyStateView()
        .padding()
        .background(Color(.systemGroupedBackground))
}

//
//  PlansEmptyStateView.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI

struct PlansEmptyStateView: View {
    let onCreateTap: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 70))
                .foregroundStyle(.blue.opacity(0.7))
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: 10) {
                Text("Нет бюджетов")
                    .font(.system(size: 24, weight: .bold))
                
                Text("Создайте бюджет для отслеживания расходов по категориям")
                    .font(.app(.body))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: onCreateTap) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                    Text("Создать бюджет")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .background(Color.blue)
                .clipShape(Capsule())
                .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
            }
            .padding(.top, 8)
            
            Spacer()
        }
    }
}

#Preview {
    PlansEmptyStateView(onCreateTap: {})
        .background(Color(.systemGroupedBackground))
}

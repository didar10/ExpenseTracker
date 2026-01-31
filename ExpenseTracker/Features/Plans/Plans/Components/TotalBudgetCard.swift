//
//  TotalBudgetCard.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI

struct TotalBudgetCard: View {
    let totalBudget: Decimal
    let totalSpent: Decimal
    
    private var progress: Double {
        guard totalBudget > 0 else { return 0 }
        return min(Double(truncating: totalSpent as NSDecimalNumber) / Double(truncating: totalBudget as NSDecimalNumber), 1.0)
    }
    
    private var percentage: Int {
        guard totalBudget > 0 else { return 0 }
        return Int(truncating: min(totalSpent / totalBudget * 100, 100) as NSDecimalNumber)
    }
    
    private var remaining: Decimal {
        totalBudget - totalSpent
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Общий бюджет")
                        .font(.app(.bodySmall))
                        .foregroundStyle(.secondary)
                    
                    Text(totalBudget.formatted(.currency(code: "KZT")))
                        .font(.system(size: 26, weight: .bold))
                        .fontDesign(.rounded)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Text("Потрачено")
                        .font(.app(.bodySmall))
                        .foregroundStyle(.secondary)
                    
                    Text(totalSpent.formatted(.currency(code: "KZT")))
                        .font(.system(size: 22, weight: .bold))
                        .fontDesign(.rounded)
                        .foregroundStyle(totalSpent > totalBudget ? .red : .green)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray6))
                    
                    Capsule()
                        .fill(progressColor)
                        .frame(width: max(geometry.size.width * progress, 0))
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 8)
            
            HStack(alignment: .center) {
                Text("\(percentage)%")
                    .font(.app(.bodySmall))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if remaining >= 0 {
                    Text("Осталось: \(remaining.formatted(.currency(code: "KZT")))")
                        .font(.app(.bodySmall))
                        .foregroundStyle(.secondary)
                } else {
                    Text("Превышено на \(abs(remaining).formatted(.currency(code: "KZT")))")
                        .font(.app(.bodySmall))
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(16)
        .cardShadow(cornerRadius: 16)
    }
    
    private var progressColor: Color {
        switch progress {
        case 0..<0.7:
            return .green
        case 0.7..<0.9:
            return .orange
        default:
            return .red
        }
    }
}

#Preview {
    TotalBudgetCard(
        totalBudget: 500000,
        totalSpent: 250000
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

//
//  BudgetPlanRow.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI

struct BudgetPlanRow: View {
    let plan: BudgetPlan
    let spent: Decimal
    let onDelete: () -> Void
    
    private var progress: Double {
        guard plan.monthlyLimit > 0 else { return 0 }
        return min(Double(truncating: spent as NSDecimalNumber) / Double(truncating: plan.monthlyLimit as NSDecimalNumber), 1.0)
    }
    
    private var percentage: Int {
        guard plan.monthlyLimit > 0 else { return 0 }
        return Int(truncating: min(spent / plan.monthlyLimit * 100, 100) as NSDecimalNumber)
    }
    
    private var remaining: Decimal {
        plan.monthlyLimit - spent
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Иконка категории
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: plan.category.colorHex).opacity(0.15))
                        .frame(width: 38, height: 38)
                    
                    Image(systemName: plan.category.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(hex: plan.category.colorHex))
                        .symbolRenderingMode(.hierarchical)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(plan.category.name)
                        .font(.app(.bodySmall))
                    
                    Text("\(spent.formatted(.currency(code: "KZT"))) из \(plan.monthlyLimit.formatted(.currency(code: "KZT")))")
                        .font(.app(.microCaption))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Процент и кнопка удаления
                HStack(spacing: 12) {
                    Text("\(percentage)%")
                        .font(.system(size: 15, weight: .bold))
                        .fontDesign(.rounded)
                        .foregroundStyle(progressColor)
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(.red.opacity(0.8))
                    }
                    .buttonStyle(.plain)
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
            .frame(height: 6)
            
            // Остаток или превышение
            HStack {
                if remaining >= 0 {
                    Text("Осталось: \(remaining.formatted(.currency(code: "KZT")))")
                        .font(.app(.microCaption))
                        .foregroundStyle(.tertiary)
                } else {
                    Text("Превышено на \(abs(remaining).formatted(.currency(code: "KZT")))")
                        .font(.app(.microCaption))
                        .foregroundStyle(.red)
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
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

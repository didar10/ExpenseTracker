//
//  CategoryStatisticRowView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Строка со статистикой категории
struct CategoryStatisticRowView: View {
    let statistic: CategoryStatistic
    let totalExpenses: Decimal
    
    var body: some View {
        HStack(spacing: 12) {
            categoryIcon
            
            categoryInfo
            
            Spacer()
            
            amountInfo
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
    
    private var categoryIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: statistic.category.colorHex).opacity(0.15))
                .frame(width: 38, height: 38)
            
            Image(systemName: statistic.category.icon)
                .foregroundStyle(Color(hex: statistic.category.colorHex))
                .font(.system(size: 18, weight: .semibold))
        }
    }
    
    private var categoryInfo: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(statistic.category.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
            
            Text(statistic.percentageString(of: totalExpenses))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
    
    private var amountInfo: some View {
        HStack(spacing: 8) {
            Text(statistic.amount.formatted(.currency(code: "KZT")))
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
    }
}

#Preview {
    CategoryStatisticRowView(
        statistic: CategoryStatistic(
            category: Category(name: "Продукты", icon: "cart.fill", colorHex: "FF6B6B"),
            amount: 125000,
            transactionCount: 15
        ),
        totalExpenses: 450000
    )
    .padding()
}

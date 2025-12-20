//
//  ExpenseRowView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import Foundation
import SwiftUI

struct ExpenseRowView: View {

    let expense: Expense

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: expense.category?.icon ?? "questionmark")
                .frame(width: 36, height: 36)
                .background(Color.green.opacity(0.2))
                .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(expense.category?.name ?? "Без категории")
                Text(expense.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("-\(expense.amount) ₸")
                .fontWeight(.semibold)
        }
    }
}

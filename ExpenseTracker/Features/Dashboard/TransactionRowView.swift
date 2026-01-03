//
//  TransactionRowView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI
import SwiftData

struct TransactionRowView: View {

    let transaction: Transaction

    @Environment(\.modelContext) private var context

    var body: some View {
        HStack(spacing: 12) {

            iconView

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.app(.body))

                if let note = transaction.note {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(amountText)
                .font(.app(.body))
                .foregroundColor(amountColor)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .contextMenu {
            Button(role: .destructive) {
                delete()
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
}

// MARK: - Logic
private extension TransactionRowView {

    func delete() {
        context.delete(transaction)

        do {
            try context.save()
        } catch {
            print("❌ Failed to delete transaction:", error)
        }
    }
}

// MARK: - UI helpers
private extension TransactionRowView {

    var iconView: some View {
        ZStack {
            Circle()
                .fill(iconBackgroundColor)
                .frame(width: 36, height: 36)

            Image(systemName: iconName)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .semibold))
        }
    }

    var title: String {
        transaction.type == .income
        ? "Доход"
        : transaction.category?.name ?? "Расход"
    }

    var iconName: String {
        transaction.type == .income
        ? "arrow.down.circle.fill"
        : transaction.category?.icon ?? "questionmark"
    }

    var iconBackgroundColor: Color {
        transaction.type == .income
        ? .green
        : Color(hex: transaction.category?.colorHex ?? "#34C759")
    }

    var amountText: String {
        let sign = transaction.type == .income ? "+" : "−"
        return "\(sign)\(transaction.amount.formatted(.currency(code: "KZT")))"
    }

    var amountColor: Color {
        transaction.type == .income ? .green : .black
    }
}

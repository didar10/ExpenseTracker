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
    @State private var showDeleteConfirmation = false

    var body: some View {
        HStack(spacing: 12) {

            iconView

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    AppText(title, style: .bodySmaller)
                    
                    if let note = transaction.note, !note.isEmpty {
                        Image(systemName: "text.bubble")
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)
                    }
                }

                if let note = transaction.note, !note.isEmpty {
                    AppText(note, style: .microCaption, color: .secondary)
                        .lineLimit(1)
                }
            }

            Spacer()
            
            // Применяем .rounded design на уровне view
            Text(amountText)
                .font(.app(.bodySmaller))
                .fontDesign(.rounded)
                .foregroundStyle(amountColor)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 2)
        .contentShape(Rectangle())
        .contextMenu {
            Button {
                showDeleteConfirmation = true
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
        .confirmationDialog("Удалить транзакцию?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Удалить", role: .destructive) {
                delete()
            }
            Button("Отмена", role: .cancel) { }
        }
    }
}

// MARK: - Logic
private extension TransactionRowView {

    func delete() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        
        withAnimation {
            context.delete(transaction)
        }

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
                .fill(iconBackgroundColor.opacity(0.15))
                .frame(width: 38, height: 38)

            Image(systemName: iconName)
                .foregroundStyle(iconBackgroundColor)
                .font(.system(size: 18, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
        }
        .circleShadow()
    }

    var title: String {
        transaction.type == .income
        ? "Доход"
        : transaction.category?.name ?? "Расход"
    }

    var iconName: String {
        transaction.type == .income
        ? "arrow.down.circle.fill"
        : transaction.category?.icon ?? "questionmark.circle.fill"
    }

    var iconBackgroundColor: Color {
        transaction.type == .income
        ? .green
        : Color(hex: transaction.category?.colorHex ?? "#34C759")
    }

    var amountText: String {
        let sign = transaction.type == .income ? "+" : "−"
        return "\(sign) \(transaction.amount.formatted(.currency(code: "KZT")))"
    }

    var amountColor: Color {
        transaction.type == .income ? .green : .primary
    }
}

//
//  TransactionRowView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI
import SwiftData

struct TransactionRowView: View {

    // MARK: - Properties

    let transaction: Transaction

    @Environment(\.modelContext) private var context
    @State private var showDeleteConfirmation = false

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            iconView

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    AppText(title, style: .bodySmaller)

                    if let note = transaction.note, !note.isEmpty {
                        AppImage.noteBubble
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)
                    }
                }

                if let note = transaction.note, !note.isEmpty {
                    AppText(note, style: .microCaption, color: AppColor.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

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
                Label(AppString.delete, systemImage: "trash")
            }
        }
        .confirmationDialog(AppString.deleteTransaction, isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button(AppString.delete, role: .destructive) {
                delete()
            }
            Button(AppString.cancel, role: .cancel) { }
        }
    }
}

// MARK: - Actions
private extension TransactionRowView {

    func delete() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)

        withAnimation {
            context.delete(transaction)
        }

        do {
            try context.save()
        } catch {
            print("Failed to delete transaction:", error)
        }
    }
}

// MARK: - Subviews
private extension TransactionRowView {

    var iconView: some View {
        ZStack {
            Circle()
                .fill(iconBackgroundColor.opacity(0.15))
                .frame(width: 38, height: 38)

            transactionIcon
                .foregroundStyle(iconBackgroundColor)
                .font(.system(size: 18, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
        }
        .circleShadow()
    }
}

// MARK: - Computed Properties
private extension TransactionRowView {

    var title: String {
        transaction.type == .income
        ? AppString.income
        : transaction.category?.name ?? AppString.noCategory
    }

    var transactionIcon: Image {
        transaction.type == .income
        ? AppImage.incomeArrow
        : Image(systemName: transaction.category?.icon ?? "minus")
    }

    var iconBackgroundColor: Color {
        transaction.type == .income
        ? AppColor.income
        : Color(hex: transaction.category?.colorHex ?? "#8E8E93")
    }

    var amountText: String {
        let sign = transaction.type == .income ? "+" : "−"
        return "\(sign) \(transaction.amount.formatted(.currency(code: AppString.currencyCode)))"
    }

    var amountColor: Color {
        transaction.type == .income ? AppColor.income : AppColor.textPrimary
    }
}

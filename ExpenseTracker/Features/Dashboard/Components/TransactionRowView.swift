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
    /// Не задан там, где строка только показывает операцию (список категории):
    /// тогда она не кнопка и не предлагает редактирование
    var onTap: (() -> Void)?
    var onRepeat: (() -> Void)?
    /// Не задан — строка удаляет операцию сама, с подтверждением.
    /// Задан — удаление сразу, отмену предлагает экран
    var onDelete: (() -> Void)?

    @Environment(\.repositories) private var repositories

    @State private var showingDeleteConfirmation = false
    @State private var showingSaveError = false

    // MARK: - Body

    var body: some View {
        row
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityActions { accessibilityActionButtons }
            .contextMenu {
                if let onTap {
                    Button(action: onTap) {
                        Label { Text(AppString.edit) } icon: { AppImage.pencil }
                    }
                }

                if let onRepeat {
                    Button(action: onRepeat) {
                        Label { Text(AppString.repeatTransaction) } icon: { AppImage.repeatAction }
                    }
                }

                Button(role: .destructive, action: requestDelete) {
                    Label { Text(AppString.delete) } icon: { AppImage.trash }
                }
            }
            .alert(AppString.deleteTransaction, isPresented: $showingDeleteConfirmation) {
                Button(AppString.delete, role: .destructive) { delete() }
                Button(AppString.cancel, role: .cancel) {}
            } message: {
                Text(AppString.cannotUndo)
            }
            .saveErrorAlert(isPresented: $showingSaveError)
    }
}

// MARK: - Actions
private extension TransactionRowView {

    func requestDelete() {
        if let onDelete {
            onDelete()
        } else {
            showingDeleteConfirmation = true
        }
    }

    func delete() {
        do {
            try withAnimation(.easeOut(duration: 0.2)) {
                try repositories.transactions.delete(transaction)
            }
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        } catch {
            showingSaveError = true
        }
    }
}

// MARK: - Subviews
private extension TransactionRowView {

    /// Контекстное меню неудобно в VoiceOver — те же действия в ротор
    @ViewBuilder
    var accessibilityActionButtons: some View {
        if let onRepeat {
            Button(AppString.repeatTransaction, action: onRepeat)
        }

        if onDelete != nil {
            Button(AppString.delete, action: requestDelete)
        }
    }

    @ViewBuilder
    var row: some View {
        if let onTap {
            Button(action: onTap) {
                rowContent
            }
            .buttonStyle(HighlightRowButtonStyle())
            .accessibilityHint(AppString.edit)
        } else {
            rowContent
        }
    }

    var rowContent: some View {
        HStack(spacing: AppSpacing.medium) {
            iconView

            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                AppText(title, style: .bodySmaller)
                    .lineLimit(1)

                if let note = transaction.note, !note.isEmpty {
                    AppText(note, style: .microCaption, color: AppColor.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: AppSpacing.small)

            Text(amountText)
                .font(.app(.bodySmaller))
                .fontDesign(.rounded)
                .monospacedDigit()
                .foregroundStyle(amountColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, AppSpacing.mediumSmall)
        .padding(.vertical, AppSpacing.medium)
        .contentShape(Rectangle())
        .cardShadow(cornerRadius: AppRadius.card)
    }

    var iconView: some View {
        ZStack {
            Circle()
                .fill(iconColor.opacity(0.15))
                .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)

            transactionIcon
                .foregroundStyle(iconColor)
                .font(.system(size: AppSize.glyphRow, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
        }
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
        : Image(systemName: transaction.category?.icon ?? Constants.fallbackIcon)
    }

    var iconColor: Color {
        transaction.type == .income
        ? AppColor.income
        : Color(hex: transaction.category?.colorHex ?? Constants.fallbackColorHex)
    }

    var amountText: String {
        let sign = transaction.type == .income ? Constants.plusSign : Constants.minusSign
        return "\(sign) \(transaction.amount.formatted(.currency(code: AppString.currencyCode)))"
    }

    var amountColor: Color {
        transaction.type == .income ? AppColor.income : AppColor.textPrimary
    }

    /// VoiceOver читает строку целиком: категория, сумма и комментарий
    var accessibilityLabel: String {
        [title, amountText, transaction.note ?? ""]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}

// MARK: - Constants
private extension TransactionRowView {

    enum Constants {
        static let fallbackIcon = "minus"
        static let fallbackColorHex = "#8E8E93"
        static let plusSign = "+"
        /// Минус для сумм — типографский, а не дефис
        static let minusSign = "−"
    }
}

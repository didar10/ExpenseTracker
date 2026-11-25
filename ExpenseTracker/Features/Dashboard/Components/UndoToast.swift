//
//  UndoToast.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Тост «Операция удалена · Отменить» над таббаром: заменяет подтверждение перед удалением.
/// Карточка с обводкой без тени, кнопка — обычный outline-контрол
struct UndoToast: View {

    // MARK: - Properties

    let message: String
    let onUndo: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            Text(message)
                .font(DS.Font.bodyBold)
                .foregroundStyle(DS.Color.ink)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onUndo) {
                HStack(spacing: DS.Spacing.xs) {
                    AppImage.undo
                        .font(.system(size: DS.Size.iconS, weight: .bold))
                        .accessibilityHidden(true)

                    Text(AppString.undo)
                        .font(DS.Font.control)
                }
                .padding(.horizontal, DS.Spacing.md)
                .frame(minHeight: DS.Size.control)
            }
            .buttonStyle(.outlineClick(radius: DS.Radius.control, fill: DS.Color.bg))
        }
        .padding(.leading, DS.Spacing.lg)
        .padding(.trailing, DS.Spacing.sm)
        .padding(.vertical, DS.Spacing.sm)
        .background(DS.Color.surface, in: RoundedRectangle(cornerRadius: DS.Radius.card))
        .brutalBorder(radius: DS.Radius.card)
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Светлая") {
    UndoToast(message: AppString.transactionDeleted) {}
        .padding(DS.Spacing.xl)
        .background(DS.Color.bg)
}

#Preview("Темная") {
    UndoToast(message: AppString.transactionDeleted) {}
        .padding(DS.Spacing.xl)
        .background(DS.Color.bg)
        .preferredColorScheme(.dark)
}
#endif

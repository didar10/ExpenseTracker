//
//  BrutalAlert.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

extension View {

    /// Подтверждение опасного действия: заголовок, текст, красная кнопка и «Отмена».
    /// Обводка без тени, фон затемнен на 35%. Тап по затемнению — отмена
    func brutalAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        confirmTitle: String,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void = {}
    ) -> some View {
        modifier(BrutalOverlayPresenter(isPresented: isPresented) { dismiss in
            BrutalAlertCard(
                title: title,
                message: message,
                confirmTitle: confirmTitle,
                onConfirm: { dismiss(onConfirm) },
                onCancel: { dismiss(onCancel) }
            )
        })
    }
}

/// Карточка алерта. Отдельно от модификатора — для превью и снапшотов
struct BrutalAlertCard: View {

    // MARK: - Properties

    let title: String
    var message: String?
    let confirmTitle: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            Text(title)
                .font(DS.Font.dialogTitle)
                .foregroundStyle(DS.Color.ink)
                .accessibilityAddTraits(.isHeader)

            if let message {
                Text(message)
                    .font(DS.Font.bodySmall)
                    .foregroundStyle(DS.Color.ink2)
                    .padding(.top, Metrics.messageTop)
            }

            VStack(spacing: Metrics.buttonSpacing) {
                // Удаление — главное действие алерта: красная заливка и красная тень
                Button(action: onConfirm) {
                    Text(confirmTitle)
                        .font(DS.Font.buttonSmall)
                        .frame(minHeight: DS.Size.menuRow)
                }
                .buttonStyle(PressIntoShadowStyle(variant: .dangerFilled))

                // «Отмена» без тени — «щелчок обводки»
                Button(action: onCancel) {
                    Text(AppString.cancel)
                        .font(DS.Font.buttonSmall)
                        .frame(maxWidth: .infinity, minHeight: DS.Size.menuRow)
                }
                .buttonStyle(.outlineClick)
            }
            .padding(.top, DS.Spacing.lg)
        }
        .multilineTextAlignment(.center)
        .padding(.top, Metrics.topPadding)
        .padding(.horizontal, Metrics.horizontalPadding)
        .padding(.bottom, DS.Spacing.lg)
        .frame(maxWidth: Metrics.maxWidth)
        .background(DS.Color.surface, in: RoundedRectangle(cornerRadius: DS.Radius.dialog))
        .brutalBorder(radius: DS.Radius.dialog)
        .padding(.horizontal, DS.Spacing.xxl)
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/TxDeleteConfirm.html` (.dlg)
    static let topPadding: CGFloat = 22
    static let horizontalPadding: CGFloat = 18
    static let messageTop: CGFloat = 6
    static let buttonSpacing: CGFloat = 10
    /// На iPad алерт не растягивается на весь экран
    static let maxWidth: CGFloat = 420
}

// MARK: - Previews

#if DEBUG
private struct BrutalAlertPreview: View {

    @State private var isPresented = true

    var body: some View {
        DSPreviewGallery {
            PrimaryButton(title: "Удалить операцию", variant: .danger) { isPresented = true }
        }
        .brutalAlert(
            isPresented: $isPresented,
            title: "Удалить операцию?",
            message: "«Продукты на неделю» −4 850 ₸. Баланс счёта пересчитается.",
            confirmTitle: "Удалить",
            onConfirm: {}
        )
    }
}

#Preview("Светлая") {
    BrutalAlertPreview()
}

#Preview("Темная") {
    BrutalAlertPreview()
        .preferredColorScheme(.dark)
}

#Preview("Без текста · xxxLarge") {
    ZStack {
        DS.Color.bg.ignoresSafeArea()
        DS.Color.scrim.ignoresSafeArea()
        BrutalAlertCard(title: "Удалить счёт?", confirmTitle: "Удалить", onConfirm: {}, onCancel: {})
    }
    .environment(\.dynamicTypeSize, .xxxLarge)
}
#endif

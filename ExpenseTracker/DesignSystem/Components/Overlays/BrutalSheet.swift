//
//  BrutalSheet.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

extension View {

    /// Лист: фон bg, радиус 22, серый граббер, без темной обводки.
    /// Заголовок sheetTitle и кнопка «Готово», которая закрывает лист
    func brutalSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        title: String,
        detents: Set<PresentationDetent> = [.medium, .large],
        onDone: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        sheet(isPresented: isPresented) {
            BrutalSheetLayout(title: title, onDone: onDone, content: content)
                .brutalSheetPresentation(detents: detents)
        }
    }

    func brutalSheet<Item: Identifiable, SheetContent: View>(
        item: Binding<Item?>,
        title: @escaping (Item) -> String,
        detents: Set<PresentationDetent> = [.medium, .large],
        onDone: @escaping () -> Void = {},
        @ViewBuilder content: @escaping (Item) -> SheetContent
    ) -> some View {
        sheet(item: item) { item in
            BrutalSheetLayout(title: title(item), onDone: onDone) { content(item) }
                .brutalSheetPresentation(detents: detents)
        }
    }

    fileprivate func brutalSheetPresentation(detents: Set<PresentationDetent>) -> some View {
        presentationDetents(detents)
            .presentationBackground(DS.Color.bg)
            .presentationCornerRadius(DS.Radius.sheet)
            // Свой граббер: системный не того цвета и размера
            .presentationDragIndicator(.hidden)
    }
}

/// Раскладка листа: граббер, заголовок с «Готово», контент.
/// Отдельно от модификатора — для превью и снапшотов
struct BrutalSheetLayout<Content: View>: View {

    // MARK: - Properties

    let title: String
    var onDone: () -> Void = {}
    @ViewBuilder let content: Content

    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    init(title: String, onDone: @escaping () -> Void = {}, @ViewBuilder content: () -> Content) {
        self.title = title
        self.onDone = onDone
        self.content = content()
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            Capsule()
                .fill(DS.Color.grabber)
                .frame(width: Metrics.grabberWidth, height: Metrics.grabberHeight)
                .padding(.bottom, DS.Spacing.md)
                .accessibilityHidden(true)

            header
                .padding(.bottom, Metrics.headerBottom)

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding(.top, Metrics.topPadding)
        .padding(.horizontal, DS.Spacing.xl)
        .background(DS.Color.bg)
    }

    private var header: some View {
        HStack(spacing: DS.Spacing.md) {
            Text(title)
                .font(DS.Font.sheetTitle)
                .foregroundStyle(DS.Color.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            Button {
                onDone()
                dismiss()
            } label: {
                Text(AppString.done)
                    .font(DS.Font.control)
                    .padding(.horizontal, DS.Spacing.md)
                    .frame(minHeight: Metrics.doneHeight)
            }
            .buttonStyle(.outlineClick)
        }
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/AccountSelection.html` (.sheetW, .grab, .sh)
    static let topPadding: CGFloat = 10
    static let grabberWidth: CGFloat = 40
    static let grabberHeight: CGFloat = 5
    static let headerBottom: CGFloat = 14
    static let doneHeight: CGFloat = 34
}

// MARK: - Previews

#if DEBUG
private struct BrutalSheetPreview: View {

    @State private var isPresented = true

    var body: some View {
        DSPreviewGallery {
            PrimaryButton(title: "Открыть лист") { isPresented = true }
        }
        .brutalSheet(isPresented: $isPresented, title: "Выбор счёта") {
            Card(padding: nil) {
                VStack(spacing: .zero) {
                    TransactionRow(title: "Все счета", subtitle: "975 050 ₸", amount: "", icon: Image(systemName: "wallet.bifold"), color: .green)
                    ListDivider()
                    TransactionRow(title: "Наличные", subtitle: "32 000 ₸", amount: "", icon: Image(systemName: "banknote"), color: .green)
                }
            }
        }
    }
}

#Preview("Светлая") {
    BrutalSheetPreview()
}

#Preview("Темная") {
    BrutalSheetPreview()
        .preferredColorScheme(.dark)
}
#endif

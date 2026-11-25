//
//  NoteField.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Поле «Заметка» высотой 44: без метки, плейсхолдер серым. В фокусе обводка утолщается
struct NoteField: View {

    // MARK: - Properties

    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding

    // MARK: - Body

    var body: some View {
        TextField(
            AppString.notePlaceholder,
            text: $text,
            prompt: Text(AppString.notePlaceholder).foregroundStyle(DS.Color.ink2)
        )
        .font(DS.Font.body)
        .foregroundStyle(DS.Color.ink)
        .submitLabel(.done)
        .focused(isFocused)
        .onSubmit { isFocused.wrappedValue = false }
        .padding(.horizontal, Metrics.horizontalPadding)
        .frame(minHeight: DS.Size.control)
        .background(DS.Color.surface, in: RoundedRectangle(cornerRadius: DS.Radius.card))
        .brutalBorder(
            radius: DS.Radius.card,
            lineWidth: isFocused.wrappedValue ? DS.Stroke.pressed : DS.Stroke.regular
        )
        .contentShape(Rectangle())
        .onTapGesture { isFocused.wrappedValue = true }
    }
}

// MARK: - Metrics

private enum Metrics {
    /// Размеры из `Design/html/AddTransaction.html` (.note)
    static let horizontalPadding: CGFloat = 14
}

// MARK: - Previews

#if DEBUG
private struct NoteFieldPreview: View {

    @State var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        NoteField(text: $text, isFocused: $isFocused)
    }
}

private struct NoteFieldGallery: View {

    var body: some View {
        DSPreviewGallery {
            DSPreviewCase("Пусто") {
                NoteFieldPreview(text: "")
            }
            DSPreviewCase("С текстом") {
                NoteFieldPreview(text: "Продукты на неделю")
            }
        }
    }
}

#Preview("Светлая") {
    NoteFieldGallery()
}

#Preview("Темная") {
    NoteFieldGallery()
        .preferredColorScheme(.dark)
}
#endif

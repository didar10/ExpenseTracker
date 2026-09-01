//
//  TransactionDetailsView.swift
//  ExpenseTracker
//
//  Created by Didar on 23.01.2026.
//

import SwiftUI

// MARK: - Date Selection View

struct DateSelectionView: View {

    // MARK: - Properties

    @Binding var date: Date
    /// Вызывается перед открытием календаря: экран убирает клавиатуру заметки
    var onOpen: () -> Void = {}

    @State private var showingDatePicker = false

    // MARK: - Computed Properties

    private var dateText: String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return AppString.today
        }

        if calendar.isDateInYesterday(date) {
            return AppString.yesterday
        }

        return date.isInCurrentYear
            ? date.formatted(.dateTime.day().month(.abbreviated))
            : date.formatted(.dateTime.day().month(.twoDigits).year(.twoDigits))
    }

    // MARK: - Body

    var body: some View {
        Button {
            onOpen()
            showingDatePicker = true
        } label: {
            VStack(spacing: AppSpacing.xSmall) {
                AppImage.calendar
                    .font(.system(size: AppSize.glyphLarge))
                    .foregroundStyle(AppColor.textSecondary)

                Text(dateText)
                    .font(.app(.caption))
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, AppSpacing.smaller)
            }
            .frame(width: AppSize.dateTile)
            .frame(height: AppSize.inlineTile)
            .card(cornerRadius: AppRadius.card)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AppString.date)
        .accessibilityValue(dateText)
        .accessibilityHint(AppString.selectDate)
        .sheet(isPresented: $showingDatePicker) {
            datePickerSheet
        }
    }

    // MARK: - Subviews

    private var datePickerSheet: some View {
        NavigationStack {
            DatePicker(
                AppString.selectDate,
                selection: $date,
                in: ...Date.now,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding(AppSpacing.large)
            .navigationTitle(AppString.date)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(AppString.done) {
                        showingDatePicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationBackground(AppColor.background)
    }
}

// MARK: - Note Input View

struct NoteInputView: View {

    // MARK: - Properties

    @Binding var note: String
    @FocusState.Binding var isFocused: Bool

    // MARK: - Body

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            AppImage.textAlign
                .font(.system(size: AppSize.glyphLarge))
                .foregroundStyle(AppColor.textSecondary)
                .padding(.top, AppSpacing.large)

            TextField(AppString.addComment, text: $note, axis: .vertical)
                .font(.app(.body))
                .lineLimit(2...4)
                .focused($isFocused)
                .padding(.vertical, AppSpacing.large)
        }
        .padding(.horizontal, AppSpacing.large)
        .card(cornerRadius: AppRadius.card)
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
    }
}

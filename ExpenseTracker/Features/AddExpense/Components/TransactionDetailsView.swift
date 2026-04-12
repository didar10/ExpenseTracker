//
//  TransactionDetailsView.swift
//  ExpenseTracker
//
//  Created by Didar on 23.01.2026.
//

import SwiftUI

struct TransactionDetailsView: View {

    // MARK: - Properties

    @Binding var date: Date
    @Binding var note: String

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            DateSelectionView(date: $date)
            NoteInputView(note: $note)
        }
    }
}

// MARK: - Date Selection View

struct DateSelectionView: View {

    // MARK: - Properties

    @Binding var date: Date
    @State private var showingDatePicker = false

    // MARK: - Computed Properties

    private var dateText: String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return AppString.today
        } else if calendar.isDateInYesterday(date) {
            return AppString.yesterday
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yy"
            return formatter.string(from: date)
        }
    }

    // MARK: - Body

    var body: some View {
        Button {
            showingDatePicker = true
        } label: {
            VStack(spacing: 4) {
                AppImage.calendar
                    .font(.system(size: 18))
                    .foregroundStyle(AppColor.textSecondary)

                Text(dateText)
                    .font(.app(.caption))
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)
            }
            .frame(width: 90)
            .frame(height: 60)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppColor.cardBackground)
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDatePicker) {
            NavigationStack {
                DatePicker(
                    AppString.selectDate,
                    selection: $date,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
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
        }
    }
}

// MARK: - Note Input View

struct NoteInputView: View {

    // MARK: - Properties

    @Binding var note: String

    // MARK: - Body

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AppImage.textAlign
                .foregroundStyle(AppColor.textSecondary)
                .font(.system(size: 18))
                .padding(.top, 14)

            TextField(AppString.addComment, text: $note, axis: .vertical)
                .font(.app(.body))
                .lineLimit(2...4)
                .padding(.vertical, 14)
        }
        .padding(.horizontal, 16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColor.cardBackground)
        }
    }
}

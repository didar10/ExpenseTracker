//
//  TransactionDetailsView.swift
//  ExpenseTracker
//
//  Created by Didar on 23.01.2026.
//

import SwiftUI

struct TransactionDetailsView: View {
    @Binding var date: Date
    @Binding var note: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Date Picker
            DateSelectionView(date: $date)
            
            // Note Field
            NoteInputView(note: $note)
        }
    }
}

// MARK: - Date Selection View

struct DateSelectionView: View {
    @Binding var date: Date
    @State private var showingDatePicker = false
    
    private var dateText: String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Сегодня"
        } else if calendar.isDateInYesterday(date) {
            return "Вчера"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yy"
            return formatter.string(from: date)
        }
    }
    
    var body: some View {
        Button {
            showingDatePicker = true
        } label: {
            VStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 18))
                    .foregroundStyle(.secondary)
                
                Text(dateText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .frame(width: 90)
            .frame(height: 60)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemBackground))
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDatePicker) {
            NavigationStack {
                DatePicker(
                    "Выберите дату",
                    selection: $date,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                .navigationTitle("Дата")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Готово") {
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
    @Binding var note: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "text.alignleft")
                .foregroundStyle(.secondary)
                .font(.system(size: 18))
                .padding(.top, 14)
            
            TextField("Добавить комментарий...", text: $note, axis: .vertical)
                .font(.app(.body))
                .lineLimit(2...4)
                .padding(.vertical, 14)
        }
        .padding(.horizontal, 16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        }
    }
}

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
    
    var body: some View {
        HStack {
            Image(systemName: "calendar")
                .foregroundStyle(.secondary)
                .font(.system(size: 18))
            
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
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

//
//  ComponentExamples.swift
//  ExpenseTracker
//
//  Created by Didar on 23.01.2026.
//
//  Этот файл содержит примеры использования переиспользуемых компонентов
//

import SwiftUI

// MARK: - TransactionTypePickerView Examples

struct TransactionTypePickerExamples: View {
    @State private var selectedType: TransactionType = .expense
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Выбран: \(selectedType.rawValue)")
                .font(.headline)
            
            TransactionTypePickerView(selectedType: $selectedType)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - TransactionAmountView Examples

struct TransactionAmountViewExamples: View {
    @State private var amounts = ["0", "1234", "1234.56", "999999.99"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(amounts, id: \.self) { amount in
                    VStack {
                        Text("Amount: \(amount)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        TransactionAmountView(amount: amount)
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - CategorySelectionView Examples

struct CategorySelectionViewExamples: View {
    @State private var selectedCategory: Category?

    // Пример категорий (в реальном приложении используйте @Query)
    let sampleCategories: [Category] = []

    var body: some View {
        VStack {
            if let selected = selectedCategory {
                Text("Выбрана: \(selected.name)")
                    .font(.headline)
                    .padding()
            }

            CategorySelectionView(
                categories: sampleCategories,
                selectedCategory: $selectedCategory
            )

            Spacer()
        }
    }
}

// MARK: - TransactionDetailsView Examples

struct TransactionDetailsViewExamples: View {
    @State private var date = Date.now
    @State private var note = ""
    
    var body: some View {
        VStack {
            Text("Дата: \(date.formatted(date: .abbreviated, time: .omitted))")
                .font(.headline)
            
            Text("Комментарий: \(note.isEmpty ? "Пусто" : note)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            TransactionDetailsView(
                date: $date,
                note: $note
            )
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - SuccessOverlayView Examples

struct SuccessOverlayViewExamples: View {
    @State private var showSuccess = false
    
    var body: some View {
        ZStack {
            VStack {
                Button("Показать Success") {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showSuccess = true
                    }
                    
                    // Автоматически скрыть через 2 секунды
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showSuccess = false
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            
            if showSuccess {
                SuccessOverlayView(isShowing: showSuccess)
            }
        }
    }
}

// MARK: - CategoryItemView Examples

struct CategoryItemViewExamples: View {
    @State private var selectedCategory: Category?

    // Пример категорий
    let sampleCategories: [Category] = []

    var body: some View {
        VStack {
            CategorySelectionView(
                categories: sampleCategories,
                selectedCategory: $selectedCategory
            )

            Spacer()
        }
        .padding()
    }
}

// MARK: - Composite Example (использование нескольких компонентов вместе)

struct CompositeComponentExample: View {
    @State private var type: TransactionType = .expense
    @State private var amount = "1234.56"
    @State private var selectedCategory: Category?
    @State private var date = Date.now
    @State private var note = ""
    
    let categories: [Category] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Type Picker
                    TransactionTypePickerView(selectedType: $type)
                    
                    // Amount
                    TransactionAmountView(amount: amount)
                        .padding(.horizontal)
                    
                    // Categories (только для расходов)
                    if type == .expense {
                        CategorySelectionView(
                            categories: categories,
                            selectedCategory: $selectedCategory
                        )
                    }
                    
                    // Details
                    TransactionDetailsView(
                        date: $date,
                        note: $note
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Пример композиции")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview Helpers

#Preview("Type Picker") {
    TransactionTypePickerExamples()
}

#Preview("Amount View") {
    TransactionAmountViewExamples()
}

#Preview("Category Selection") {
    CategorySelectionViewExamples()
}

#Preview("Transaction Details") {
    TransactionDetailsViewExamples()
}

#Preview("Success Overlay") {
    SuccessOverlayViewExamples()
}

#Preview("Category Items") {
    CategoryItemViewExamples()
}

#Preview("Composite Example") {
    CompositeComponentExample()
}

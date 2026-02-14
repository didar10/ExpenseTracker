//
//  AddBudgetPlanView.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI
import SwiftData

struct AddBudgetPlanView: View {
    let categories: [Category]
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var selectedCategory: Category?
    @State private var amount: String = ""
    @State private var selectedPeriod: BudgetPeriod = .month
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Категория
                        categorySection
                        
                        // Сумма
                        amountSection
                        
                        // Период
                        periodSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Новый бюджет")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ToolbarIconButton(icon: "xmark") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    ToolbarIconButton(icon: "checkmark", isEnabled: canSave) {
                        savePlan()
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Категория")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
            
            if categories.isEmpty {
                Text("Все категории уже используются")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .cardShadow(cornerRadius: 12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories) { category in
                            CategorySelectButton(
                                category: category,
                                isSelected: selectedCategory?.persistentModelID == category.persistentModelID
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
    
    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Лимит")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
            
            HStack {
                TextField("0", text: $amount)
                    .font(.system(size: 28, weight: .bold))
                    .fontDesign(.rounded)
                    .keyboardType(.decimalPad)
                
                Text("₸")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .padding()
            .card(cornerRadius: 12)
        }
    }
    
    private var periodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Период")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                ForEach(BudgetPeriod.allCases, id: \.self) { period in
                    Button {
                        selectedPeriod = period
                    } label: {
                        Text(period.rawValue)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(selectedPeriod == period ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedPeriod == period ? Color.blue : Color(uiColor: .systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
            .card(cornerRadius: 12)
        }
    }
    
    // MARK: - Validation & Save
    
    private var canSave: Bool {
        guard selectedCategory != nil else { return false }
        
        let cleanedAmount = amount.replacingOccurrences(of: ",", with: ".")
        guard let amountValue = Decimal(string: cleanedAmount), amountValue > 0 else {
            return false
        }
        
        return true
    }
    
    private func savePlan() {
        guard let category = selectedCategory else {
            print("❌ Category not selected")
            return
        }
        
        let cleanedAmount = amount.replacingOccurrences(of: ",", with: ".")
        guard let amountValue = Decimal(string: cleanedAmount), amountValue > 0 else {
            print("❌ Invalid amount: '\(amount)'")
            return
        }
        
        let plan = BudgetPlan(
            category: category,
            monthlyLimit: amountValue,
            period: selectedPeriod
        )
        
        context.insert(plan)
        
        do {
            try context.save()
            print("✅ Budget plan saved: \(category.name) - \(amountValue) ₸")
        } catch {
            print("❌ Failed to save: \(error)")
        }
        
        dismiss()
    }
}

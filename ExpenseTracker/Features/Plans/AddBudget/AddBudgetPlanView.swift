//
//  AddBudgetPlanView.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI
import SwiftData

struct AddBudgetPlanView: View {

    // MARK: - Properties

    let categories: [Category]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var selectedCategory: Category?
    @State private var amount: String = ""
    @State private var selectedPeriod: BudgetPeriod = .month

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        categorySection
                        amountSection
                        periodSection
                    }
                    .padding()
                }
            }
            .navigationTitle(AppString.newBudget)
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
}

// MARK: - Subviews
private extension AddBudgetPlanView {

    var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppText(AppString.category, style: .caption, color: AppColor.textSecondary)

            if categories.isEmpty {
                AppText(AppString.allCategoriesUsed, style: .bodySmaller, color: AppColor.textSecondary)
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

    var amountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppText(AppString.limit, style: .caption, color: AppColor.textSecondary)

            HStack {
                TextField("0", text: $amount)
                    .font(.system(size: 28, weight: .bold))
                    .fontDesign(.rounded)
                    .keyboardType(.decimalPad)

                AppText(AppString.currencySymbol, style: .title, color: AppColor.textSecondary)
            }
            .padding()
            .card(cornerRadius: 12)
        }
    }

    var periodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppText(AppString.period, style: .caption, color: AppColor.textSecondary)

            HStack(spacing: 12) {
                ForEach(BudgetPeriod.allCases, id: \.self) { period in
                    Button {
                        selectedPeriod = period
                    } label: {
                        Text(period.rawValue)
                            .font(.app(.bodySmaller))
                            .foregroundStyle(selectedPeriod == period ? AppColor.textWhite : AppColor.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedPeriod == period ? AppColor.accent : AppColor.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
            .card(cornerRadius: 12)
        }
    }
}

// MARK: - Actions
private extension AddBudgetPlanView {

    var canSave: Bool {
        guard selectedCategory != nil else { return false }
        let cleanedAmount = amount.replacingOccurrences(of: ",", with: ".")
        guard let amountValue = Decimal(string: cleanedAmount), amountValue > 0 else { return false }
        return true
    }

    func savePlan() {
        guard let category = selectedCategory else { return }
        let cleanedAmount = amount.replacingOccurrences(of: ",", with: ".")
        guard let amountValue = Decimal(string: cleanedAmount), amountValue > 0 else { return }

        let plan = BudgetPlan(
            category: category,
            monthlyLimit: amountValue,
            period: selectedPeriod
        )

        context.insert(plan)
        try? context.save()
        dismiss()
    }
}

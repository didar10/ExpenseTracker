//
//  PlansView.swift
//  ExpenseTracker
//
//  Created by Didar on 04.01.2026.
//

import SwiftUI
import SwiftData

struct PlansView: View {
    
    @Query(sort: \BudgetPlan.createdAt, order: .reverse)
    private var budgetPlans: [BudgetPlan]
    
    @Query(sort: \Category.name)
    private var categories: [Category]
    
    @Query(sort: \Transaction.date, order: .reverse)
    private var transactions: [Transaction]
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAddPlan = false
    @State private var selectedPeriod: BudgetPeriod = .month
    @State private var planToDelete: BudgetPlan?
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
              
                ScrollView {
                    VStack(spacing: 16) {
                        if filteredPlans.isEmpty {
                            PlansEmptyStateView {
                                showingAddPlan = true
                            }
                        } else {
                            // Общая статистика
                            TotalBudgetCard(totalBudget: totalBudget, totalSpent: totalSpent)
                            
                            // Список планов
                            plansListCard
                        }
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddPlan, onDismiss: {
                print("✅ Budget plan sheet dismissed")
            }) {
                AddBudgetPlanView(categories: availableCategories)
                    .environment(\.modelContext, context)
            }
            .alert("Удалить бюджет?", isPresented: $showDeleteAlert) {
                Button("Отмена", role: .cancel) {}
                Button("Удалить", role: .destructive) {
                    if let plan = planToDelete {
                        deletePlan(plan)
                    }
                }
            } message: {
                Text("Это действие нельзя отменить")
            }
            .onAppear {
                print("🔄 PlansView appeared - Total plans: \(budgetPlans.count), Filtered: \(filteredPlans.count)")
            }
        }
    }
}

// MARK: - Computed Properties
private extension PlansView {
    
    var headerView: some View {
        HStack {
            PeriodPickerButton(selectedPeriod: selectedPeriod) { period in
                selectedPeriod = period
            }
            
            Spacer()
            
            ToolbarIconButton(icon: "plus") {
                showingAddPlan = true
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }
    
    var filteredPlans: [BudgetPlan] {
        budgetPlans.filter { $0.period == selectedPeriod && $0.isActive }
    }
    
    var availableCategories: [Category] {
        let usedCategoryIDs = Set(budgetPlans
            .filter { $0.period == selectedPeriod && $0.isActive }
            .map { $0.category.persistentModelID })
        return categories.filter { !usedCategoryIDs.contains($0.persistentModelID) }
    }
    
    var totalBudget: Decimal {
        filteredPlans.reduce(0) { $0 + $1.monthlyLimit }
    }
    
    var totalSpent: Decimal {
        filteredPlans.reduce(0) { $0 + spentAmount(for: $1) }
    }
    
    func spentAmount(for plan: BudgetPlan) -> Decimal {
        let interval = selectedPeriod.dateInterval
        return transactions
            .filter { transaction in
                transaction.type == .expense &&
                transaction.category?.persistentModelID == plan.category.persistentModelID &&
                interval.contains(transaction.date)
            }
            .reduce(0) { $0 + $1.amount }
    }
    
    func deletePlan(_ plan: BudgetPlan) {
        withAnimation {
            context.delete(plan)
            try? context.save()
        }
    }
}

// MARK: - UI Components
private extension PlansView {
    
    var plansListCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(filteredPlans.enumerated()), id: \.element.persistentModelID) { index, plan in
                BudgetPlanRow(
                    plan: plan,
                    spent: spentAmount(for: plan),
                    onDelete: {
                        planToDelete = plan
                        showDeleteAlert = true
                    }
                )
                
                if index < filteredPlans.count - 1 {
                    Divider()
                        .padding(.leading, 56)
                }
            }
        }
        .padding(16)
        .cardShadow(cornerRadius: 16)
    }
}


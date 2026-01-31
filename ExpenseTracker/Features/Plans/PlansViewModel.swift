//
//  PlansViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 27.01.2026.
//

import SwiftUI
import SwiftData

@Observable
final class PlansViewModel {
    
    // MARK: - Properties
    
    var selectedPeriod: BudgetPeriod = .month
    var planToDelete: BudgetPlan?
    var showDeleteAlert = false
    var showingAddPlan = false
    
    private var budgetPlans: [BudgetPlan] = []
    private var transactions: [Transaction] = []
    
    // MARK: - Computed Properties
    
    var filteredPlans: [BudgetPlan] {
        budgetPlans.filter { $0.period == selectedPeriod && $0.isActive }
    }
    
    var totalBudget: Decimal {
        filteredPlans.reduce(0) { $0 + $1.monthlyLimit }
    }
    
    var totalSpent: Decimal {
        filteredPlans.reduce(0) { $0 + spentAmount(for: $1) }
    }
    
    // MARK: - Public Methods
    
    func updateData(budgetPlans: [BudgetPlan], transactions: [Transaction]) {
        self.budgetPlans = budgetPlans
        self.transactions = transactions
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
    
    func prepareDelete(_ plan: BudgetPlan) {
        planToDelete = plan
        showDeleteAlert = true
    }
    
    func deletePlan(context: ModelContext) {
        guard let plan = planToDelete else { return }
        
        withAnimation {
            context.delete(plan)
            try? context.save()
        }
        
        planToDelete = nil
    }
    
    func changePeriod(_ period: BudgetPeriod) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedPeriod = period
        }
    }
    
    func availableCategories(from categories: [Category]) -> [Category] {
        let usedCategoryIDs = Set(budgetPlans
            .filter { $0.period == selectedPeriod && $0.isActive }
            .map { $0.category.persistentModelID })
        return categories.filter { !usedCategoryIDs.contains($0.persistentModelID) }
    }
}

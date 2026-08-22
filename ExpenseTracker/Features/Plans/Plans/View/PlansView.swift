//
//  PlansView.swift
//  ExpenseTracker
//
//  Created by Didar on 04.01.2026.
//

import SwiftUI
import SwiftData

struct PlansView: View {

    // MARK: - Properties

    @Query(sort: \BudgetPlan.createdAt, order: .reverse)
    private var budgetPlans: [BudgetPlan]

    @Query(sort: \Category.name)
    private var categories: [Category]

    @Query(sort: \Transaction.date, order: .reverse)
    private var transactions: [Transaction]

    @Environment(\.modelContext) private var context

    @State private var showingAddPlan = false
    @State private var selectedPeriod: BudgetPeriod = .month
    @State private var isEditing = false
    @State private var planToDelete: BudgetPlan?
    @State private var showDeleteAlert = false

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: AppSpacing.large) {
                        BudgetPeriodPickerView(selectedPeriod: $selectedPeriod)

                        if filteredPlans.isEmpty {
                            PlansEmptyStateView {
                                showingAddPlan = true
                            }
                        } else {
                            TotalBudgetCard(totalBudget: totalBudget, totalSpent: totalSpent)

                            plansListCard
                        }
                    }
                    .padding(AppSpacing.large)
                    .padding(.bottom, AppSpacing.tabBarBottomInset)
                }
            }
        }
        .onChange(of: selectedPeriod) {
            isEditing = false
        }
        .sheet(isPresented: $showingAddPlan) {
            AddBudgetPlanView(categories: availableCategories)
                .environment(\.modelContext, context)
        }
        .alert(AppString.deleteBudgetConfirm, isPresented: $showDeleteAlert) {
            Button(AppString.cancel, role: .cancel) {
                planToDelete = nil
            }
            Button(AppString.delete, role: .destructive) {
                deletePlan()
            }
        } message: {
            Text(AppString.cannotUndo)
        }
    }
}

// MARK: - Computed Properties
private extension PlansView {

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

    func prepareDelete(_ plan: BudgetPlan) {
        planToDelete = plan
        showDeleteAlert = true
    }

    func deletePlan() {
        guard let plan = planToDelete else { return }

        withAnimation {
            context.delete(plan)
            try? context.save()
        }

        planToDelete = nil
    }
}

// MARK: - Subviews
private extension PlansView {

    var header: some View {
        ZStack {
            AppText(AppString.budgets, style: .title)

            HStack(spacing: AppSpacing.small) {
                Spacer()

                if !filteredPlans.isEmpty {
                    EditToggleButton(isEditing: isEditing) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditing.toggle()
                        }
                    }
                }

                ToolbarIconButton(icon: "plus", isOutlined: true) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showingAddPlan = true
                }
            }
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.large)
    }

    var plansListCard: some View {
        AppCardView {
            VStack(spacing: 0) {
                ForEach(Array(filteredPlans.enumerated()), id: \.element.persistentModelID) { index, plan in
                    BudgetPlanRow(
                        plan: plan,
                        spent: spentAmount(for: plan),
                        isEditing: isEditing,
                        onDelete: {
                            prepareDelete(plan)
                        }
                    )

                    if index < filteredPlans.count - 1 {
                        Divider()
                            .padding(.leading, AppSpacing.listDividerIndent)
                    }
                }
            }
        }
    }
}

#Preview {
    PlansView()
}

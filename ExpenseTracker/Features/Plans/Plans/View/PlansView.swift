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

    @State private var viewModel = PlansViewModel()

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: AppSpacing.xLarge) {
                        if viewModel.hasPlans {
                            ForEach(viewModel.sections) { section in
                                periodSection(section)
                            }
                        } else {
                            PlansEmptyStateView {
                                viewModel.showingAddPlan = true
                            }
                        }
                    }
                    .padding(AppSpacing.large)
                    .padding(.bottom, AppSpacing.tabBarBottomInset)
                }
            }
        }
        .onAppear(perform: syncData)
        .onChange(of: budgetPlans) { _, _ in
            syncData()
        }
        .onChange(of: transactions) { _, _ in
            syncData()
        }
        .sheet(isPresented: $viewModel.showingAddPlan) {
            AddBudgetPlanView(categories: categories, existingPlans: viewModel.activePlans)
                .environment(\.modelContext, context)
        }
        .alert(AppString.deleteBudgetConfirm, isPresented: $viewModel.showDeleteAlert) {
            Button(AppString.cancel, role: .cancel) {
                viewModel.planToDelete = nil
            }
            Button(AppString.delete, role: .destructive) {
                viewModel.deletePlan(context: context)
            }
        } message: {
            Text(AppString.cannotUndo)
        }
    }
}

// MARK: - Actions
private extension PlansView {

    func syncData() {
        viewModel.updateData(budgetPlans: budgetPlans, transactions: transactions)
    }
}

// MARK: - Subviews
private extension PlansView {

    var header: some View {
        ScreenHeaderView(title: AppString.budgets) {
            if viewModel.hasPlans {
                EditToggleButton(isEditing: viewModel.isEditing) {
                    viewModel.toggleEditing()
                }
            }

            ToolbarIconButton(icon: "plus", isOutlined: true) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                viewModel.showingAddPlan = true
            }
        }
    }

    func periodSection(_ section: BudgetPeriodSection) -> some View {
        VStack(spacing: AppSpacing.medium) {
            BudgetPeriodHeaderView(
                periodName: section.period.displayName,
                intervalTitle: section.title,
                isNextEnabled: section.isNextPeriodAvailable,
                onPrevious: {
                    viewModel.goToPreviousPeriod(section.period)
                },
                onNext: {
                    viewModel.goToNextPeriod(section.period)
                }
            )

            plansCard(for: section)
        }
    }

    func plansCard(for section: BudgetPeriodSection) -> some View {
        AppCardView(padding: AppSpacing.medium) {
            VStack(spacing: 0) {
                ForEach(Array(section.plans.enumerated()), id: \.element.persistentModelID) { index, plan in
                    BudgetPlanRow(
                        plan: plan,
                        spent: viewModel.spentAmount(for: plan),
                        isEditing: viewModel.isEditing,
                        onDelete: {
                            viewModel.prepareDelete(plan)
                        }
                    )

                    if index < section.plans.count - 1 {
                        Divider()
                            .padding(.leading, AppSpacing.compactListDividerIndent)
                    }
                }
            }
        }
    }
}

#Preview {
    PlansView()
}

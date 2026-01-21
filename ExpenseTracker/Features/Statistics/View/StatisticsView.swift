//
//  StatisticsView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    
    // MARK: - Properties
    
    @Query(sort: \Transaction.date, order: .reverse)
    private var transactions: [Transaction]
    
    @State private var viewModel = StatisticsViewModel()
    @State private var scrollOffset: CGFloat = 0
    @State private var navigationPath = NavigationPath()
    
    @Environment(\.tabBarVisibility) private var isTabBarVisible
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                MonthPickerView(
                    selectedMonth: viewModel.selectedMonth,
                    isNextDisabled: viewModel.isCurrentMonth,
                    onPrevious: { handleMonthChange(by: -1) },
                    onNext: { handleMonthChange(by: 1) }
                )
                
                ScrollView {
                    VStack(spacing: 16) {
                        TotalExpensesCardView(amount: viewModel.totalExpenses)
                        
                        if viewModel.isEmpty {
                            StatisticsEmptyStateView()
                        } else {
                            ExpensesPieChartView(
                                statistics: viewModel.statistics,
                                totalExpenses: viewModel.totalExpenses
                            )
                            
                            CategoryStatisticsListView(
                                statistics: viewModel.statistics,
                                totalExpenses: viewModel.totalExpenses,
                                selectedMonth: viewModel.selectedMonth,
                                onCategoryTap: handleCategoryTap
                            )
                        }
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .navigationDestination(for: CategoryStatistic.self) { statistic in
                CategoryTransactionsView(
                    category: statistic.category,
                    month: viewModel.selectedMonth,
                    transactions: viewModel.transactions(for: statistic.category)
                )
            }
            .onChange(of: transactions) { oldValue, newValue in
                viewModel.updateTransactions(newValue)
            }
            .onAppear {
                viewModel.updateTransactions(transactions)
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleMonthChange(by value: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            viewModel.changeMonth(by: value)
        }
    }
    
    private func handleCategoryTap(_ statistic: CategoryStatistic) {
        navigationPath.append(statistic)
    }
}

// MARK: - Hashable for Navigation

extension CategoryStatistic: Hashable {
    static func == (lhs: CategoryStatistic, rhs: CategoryStatistic) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


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
    
    @Query(sort: \Account.createdAt, order: .forward)
    private var accounts: [Account]
    
    @State private var viewModel = StatisticsViewModel()
    @State private var scrollOffset: CGFloat = 0
    @State private var navigationPath = NavigationPath()
    @State private var showingAccountsView = false
    
    @Environment(\.tabBarVisibility) private var isTabBarVisible
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // Шапка с выбором счета и месяца
                headerView
                
                ScrollView {
                    VStack(spacing: 16) {
                        if viewModel.isEmpty {
                            // Выбор периода для пустого состояния
                            periodPickerButton
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 8)
                            
                            StatisticsEmptyStateView()
                        } else {
                            ExpensesPieChartView(
                                statistics: viewModel.statistics,
                                totalExpenses: viewModel.totalExpenses
                            )
                            
                            // Выбор периода по центру
                            periodPickerButton
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            CategoryStatisticsListView(
                                statistics: viewModel.statistics,
                                totalExpenses: viewModel.totalExpenses,
                                selectedPeriod: viewModel.selectedPeriod,
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
                    period: viewModel.selectedPeriod,
                    transactions: viewModel.transactions(for: statistic.category)
                )
            }
            .sheet(isPresented: $showingAccountsView) {
                AccountSelectionSheet(
                    accounts: accounts,
                    selectedAccount: viewModel.selectedAccount,
                    onSelect: { account in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectedAccount = account
                        }
                        showingAccountsView = false
                    },
                    onShowAll: {
                        showingAccountsView = false
                    }
                )
            }
            .onChange(of: transactions) { oldValue, newValue in
                viewModel.updateTransactions(newValue)
            }
            .onChange(of: viewModel.selectedAccount) { oldValue, newValue in
                // Пересчет статистики при изменении счета
                viewModel.changeAccount(newValue)
            }
            .onAppear {
                viewModel.updateTransactions(transactions)
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleCategoryTap(_ statistic: CategoryStatistic) {
        navigationPath.append(statistic)
    }
}

// MARK: - Header View

private extension StatisticsView {
    
    var headerView: some View {
        HStack(spacing: 12) {
            accountPickerButton
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
    }
    
    var accountPickerButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            showingAccountsView = true
        } label: {
            HStack(spacing: 6) {
                if let selectedAccount = viewModel.selectedAccount {
                    ZStack {
                        Circle()
                            .fill(selectedAccount.swiftUIColor.opacity(0.2))
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: selectedAccount.icon)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(selectedAccount.swiftUIColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(selectedAccount.name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.primary)
                        
                        Text(selectedAccount.currentBalance.formatted(.currency(code: "KZT")))
                            .font(.system(size: 11, weight: .regular))
                            .fontDesign(.rounded)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Image(systemName: "square.stack.3d.up.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.black)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Все счета")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.primary)
                        
                        let totalBalance = accounts.reduce(0) { $0 + $1.currentBalance }
                        Text(totalBalance.formatted(.currency(code: "KZT")))
                            .font(.system(size: 11, weight: .regular))
                            .fontDesign(.rounded)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
            }
        }
        .buttonStyle(.plain)
    }
    
    var periodPickerButton: some View {
        Menu {
            ForEach(StatisticsPeriod.allCases) { period in
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    viewModel.changePeriod(period)
                } label: {
                    Label {
                        Text(period.rawValue)
                    } icon: {
                        if viewModel.selectedPeriod == period {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.black)
                
                Text(viewModel.selectedPeriod.rawValue)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
            }
        }
        .buttonStyle(.plain)
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


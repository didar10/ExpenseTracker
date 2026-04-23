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

    @Bindable var viewModel: StatisticsViewModel
    @State private var scrollOffset: CGFloat = 0
    @State private var navigationPath = NavigationPath()
    @State private var showingAccountsView = false

    @Query(sort: \Transaction.date, order: .reverse)
    private var transactionsTrigger: [Transaction]

    @Query(sort: \Account.createdAt, order: .forward)
    private var accountsTrigger: [Account]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.tabBarVisibility) private var isTabBarVisible

    // MARK: - Body

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                headerView

                ScrollView {
                    VStack(spacing: AppSpacing.large) {
                        if viewModel.isEmpty {
                            periodPickerButton
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, AppSpacing.small)

                            StatisticsEmptyStateView()
                        } else {
                            ExpensesPieChartView(
                                statistics: viewModel.statistics,
                                totalExpenses: viewModel.totalExpenses
                            )

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
                    .padding(AppSpacing.large)
                    .padding(.bottom, AppSpacing.tabBarBottomInset)
                }
            }
            .background(AppColor.background)
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
                    accounts: viewModel.accounts,
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
            .onChange(of: transactionsTrigger) { _, _ in
                viewModel.fetchData()
            }
            .onChange(of: accountsTrigger) { _, _ in
                viewModel.fetchData()
            }
            .onChange(of: viewModel.selectedAccount) { _, newValue in
                viewModel.changeAccount(newValue)
            }
            .onAppear {
                if viewModel.modelContext == nil {
                    viewModel.setup(with: modelContext)
                }
            }
        }
    }

    // MARK: - Actions

    private func handleCategoryTap(_ statistic: CategoryStatistic) {
        navigationPath.append(statistic)
    }
}

// MARK: - Subviews

private extension StatisticsView {

    var headerView: some View {
        HStack(spacing: AppSpacing.medium) {
            AccountPickerButton(
                selectedAccount: viewModel.selectedAccount,
                totalBalance: viewModel.totalBalance,
                action: {
                    showingAccountsView = true
                }
            )
            Spacer()
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.small)
        .background(AppColor.background)
    }

    var periodPickerButton: some View {
        Menu {
            ForEach(StatisticsPeriod.allCases) { period in
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    viewModel.changePeriod(period)
                } label: {
                    Label {
                        Text(period.displayName)
                    } icon: {
                        if viewModel.selectedPeriod == period {
                            AppImage.checkmark
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: AppSpacing.smaller) {
                AppImage.calendar
                    .font(.system(size: AppSize.glyphMedium, weight: .medium))
                    .foregroundStyle(AppColor.textPrimary)

                AppText(viewModel.selectedPeriod.displayName, style: .caption)

                AppImage.chevronDown
                    .font(.system(size: AppSize.glyphTiny, weight: .semibold))
                    .foregroundStyle(AppColor.textSecondary)
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.vertical, AppSpacing.small)
            .background {
                Capsule()
                    .fill(AppColor.cardBackground)
                    .shadow(color: AppColor.textPrimary.opacity(0.04), radius: AppSpacing.xSmall, y: 1)
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

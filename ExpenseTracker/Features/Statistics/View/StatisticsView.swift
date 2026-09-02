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

    @State private var selectedStatistic: CategoryStatistic?
    @State private var showingAccountsView = false
    @State private var isContentScrolled = false

    @Query(sort: \Transaction.date, order: .reverse)
    private var transactionsTrigger: [Transaction]

    @Query(sort: \Account.createdAt, order: .forward)
    private var accountsTrigger: [Account]

    @Environment(\.modelContext) private var modelContext

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView

                content
            }
            .background(AppColor.background)
            .navigationBarHidden(true)
            .sheet(item: $selectedStatistic) { statistic in
                CategoryTransactionsView(
                    category: statistic.category,
                    periodTitle: viewModel.periodTitle,
                    transactions: viewModel.transactions(for: statistic.category)
                )
                .presentationDragIndicator(.hidden)
            }
            .sheet(isPresented: $showingAccountsView) {
                accountSelectionSheet
            }
            .onChange(of: transactionsTrigger) { _, _ in
                viewModel.fetchData()
            }
            .onChange(of: accountsTrigger) { _, _ in
                viewModel.fetchData()
            }
            .onChange(of: viewModel.selectedAccount) { _, _ in
                viewModel.refreshStatistics()
            }
            .onAppear {
                // Экран пересоздается при каждом переключении вкладки, поэтому
                // перезагружаем данные: пока вкладка неактивна, @Query не отслеживает изменения
                viewModel.setup(with: modelContext)
            }
        }
    }

    // MARK: - Actions

    private func handleCategoryTap(_ statistic: CategoryStatistic) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedStatistic = statistic
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

            TransactionTypePickerView(selectedType: $viewModel.selectedType)
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.small)
        .background(AppColor.background)
        // Контент, уехавший под шапку, отделяется линией
        .overlay(alignment: .bottom) {
            Divider()
                .opacity(isContentScrolled ? 1 : 0)
                .animation(.easeOut(duration: 0.15), value: isContentScrolled)
        }
    }

    @ViewBuilder
    var content: some View {
        if #available(iOS 18.0, *) {
            scrollContent
                .onScrollGeometryChange(for: Bool.self) { geometry in
                    geometry.contentOffset.y > geometry.contentInsets.top
                } action: { _, isScrolled in
                    isContentScrolled = isScrolled
                }
        } else {
            scrollContent
        }
    }

    var scrollContent: some View {
        ScrollView {
            VStack(spacing: AppSpacing.large) {
                chartSection

                periodSelector
                    .frame(maxWidth: .infinity, alignment: .center)

                listSection
            }
            .padding(AppSpacing.large)
            .padding(.bottom, AppSpacing.tabBarBottomInset)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    @ViewBuilder
    var chartSection: some View {
        if viewModel.isEmpty {
            StatisticsEmptyChartView(hint: viewModel.emptyStateHint)
        } else {
            CategoryPieChartView(
                statistics: viewModel.statistics,
                totalAmount: viewModel.totalAmount,
                title: viewModel.totalTitle
            )
        }
    }

    /// Под переключателем — список категорий, а в пустом состоянии
    /// предложение снять фильтр периода, если данные скрыл именно он
    @ViewBuilder
    var listSection: some View {
        if viewModel.isEmpty {
            if viewModel.isFilteredByPeriod {
                PillActionButton(title: AppString.periodAllTime) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    viewModel.resetPeriod()
                }
            }
        } else {
            CategoryStatisticsListView(
                statistics: viewModel.statistics,
                totalAmount: viewModel.totalAmount,
                onCategoryTap: handleCategoryTap
            )
        }
    }

    /// Выбор периода со стрелками переключения на соседний период
    var periodSelector: some View {
        HStack(spacing: AppSpacing.small) {
            if viewModel.isPeriodNavigable {
                periodArrowButton(
                    image: AppImage.chevronLeft,
                    label: AppString.previousPeriod,
                    isEnabled: true,
                    action: viewModel.goToPreviousPeriod
                )
            }

            periodPickerButton

            if viewModel.isPeriodNavigable {
                periodArrowButton(
                    image: AppImage.chevronRight,
                    label: AppString.nextPeriod,
                    isEnabled: viewModel.canGoToNextPeriod,
                    action: viewModel.goToNextPeriod
                )
            }
        }
    }

    func periodArrowButton(
        image: Image,
        label: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            image
                .font(.system(size: AppSize.glyphMedium, weight: .semibold))
                .foregroundStyle(isEnabled ? AppColor.textPrimary : AppColor.textSecondary.opacity(Constants.disabledArrowOpacity))
                .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)
                .background {
                    Circle()
                        .fill(AppColor.cardBackground)
                        .shadow(color: AppColor.textPrimary.opacity(Constants.controlShadowOpacity), radius: AppSpacing.xSmall, y: AppSpacing.hairline)
                }
        }
        .buttonStyle(PressableScaleButtonStyle())
        .disabled(!isEnabled)
        .accessibilityLabel(label)
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

                AppText(viewModel.periodTitle, style: .caption)

                AppImage.chevronDown
                    .font(.system(size: AppSize.glyphTiny, weight: .semibold))
                    .foregroundStyle(AppColor.textSecondary)
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.vertical, AppSpacing.small)
            .background {
                Capsule()
                    .fill(AppColor.cardBackground)
                    .shadow(color: AppColor.textPrimary.opacity(Constants.controlShadowOpacity), radius: AppSpacing.xSmall, y: AppSpacing.hairline)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AppString.period)
        .accessibilityValue(viewModel.periodTitle)
    }

    var accountSelectionSheet: some View {
        AccountSelectionSheet(
            selectedAccount: viewModel.selectedAccount,
            onSelect: { account in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.selectedAccount = account
                }
                showingAccountsView = false
            }
        )
    }
}

// MARK: - Constants

private extension StatisticsView {

    enum Constants {
        static let disabledArrowOpacity: Double = 0.4
        static let controlShadowOpacity: Double = 0.04
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

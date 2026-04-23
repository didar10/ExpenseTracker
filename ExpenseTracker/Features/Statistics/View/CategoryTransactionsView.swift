//
//  CategoryTransactionsView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.01.2026.
//

import SwiftUI
import SwiftData

struct CategoryTransactionsView: View {

    // MARK: - Properties

    let category: Category
    let period: StatisticsPeriod
    let transactions: [Transaction]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.tabBarVisibility) private var isTabBarVisible

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            if transactions.isEmpty {
                emptyState
            } else {
                transactionsList
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: AppSpacing.xxSmall) {
                    AppText(category.name, style: .bodySmall)

                    AppText(period.displayName, style: .caption, color: AppColor.textSecondary)
                }
            }

            ToolbarItem(placement: .navigationBarLeading) {
                ToolbarIconButton(icon: "chevron.left") {
                    isTabBarVisible.wrappedValue = true
                    dismiss()
                }
            }
        }
        .onAppear {
            isTabBarVisible.wrappedValue = false
        }
    }
}

// MARK: - Subviews

private extension CategoryTransactionsView {

    var transactionsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                totalCard
                    .padding(.horizontal, AppSpacing.large)
                    .padding(.top, AppSpacing.large)

                VStack(spacing: 0) {
                    ForEach(groupedTransactions, id: \.date) { group in
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            SectionHeaderView(date: group.date)
                                .padding(.bottom, AppSpacing.xSmall)

                            ForEach(group.transactions) { transaction in
                                TransactionRowView(transaction: transaction)
                                    .padding(.horizontal, AppSpacing.mediumSmall)
                                    .padding(.vertical, AppSpacing.xSmall)
                                    .cardShadow(cornerRadius: AppRadius.large)
                            }
                        }
                        .padding(.horizontal, AppSpacing.large)
                        .padding(.bottom, AppSpacing.medium)
                    }
                }
                .padding(.top, AppSpacing.large)
            }
            .padding(.bottom, AppSpacing.xxxLarge)
        }
    }

    var totalCard: some View {
        HStack(spacing: AppSpacing.large) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .fill(Color(hex: category.colorHex).opacity(0.15))
                    .frame(width: AppSize.iconXXLarge, height: AppSize.iconXXLarge)

                Image(systemName: category.icon)
                    .foregroundStyle(Color(hex: category.colorHex))
                    .font(.system(size: AppSize.glyphBig, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                AppText(AppString.totalForPeriod, style: .sectionHeader, color: AppColor.textSecondary)

                Text(totalAmount.formatted(.currency(code: AppString.currencyCode)))
                    .font(.app(.title))
                    .fontDesign(.rounded)
                    .foregroundStyle(AppColor.textPrimary)
            }

            Spacer()
        }
        .padding(AppSpacing.large)
        .cardShadow(cornerRadius: AppRadius.card)
    }

    var emptyState: some View {
        VStack(spacing: AppSpacing.medium) {
            Image(systemName: category.icon)
                .font(.system(size: AppSize.glyphEmptyState))
                .foregroundStyle(Color(hex: category.colorHex).opacity(0.5))
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: AppSpacing.smaller) {
                AppText(AppString.noTransactions, style: .section)

                AppText(
                    AppString.noTransactionsForPeriod(category: category.name),
                    style: .sectionHeader,
                    color: AppColor.textSecondary,
                    alignment: .center
                )
                .padding(.horizontal, AppSpacing.xxxLarge)
            }
        }
    }
}

// MARK: - Data Processing

private extension CategoryTransactionsView {

    struct TransactionGroup {
        let date: Date
        let transactions: [Transaction]
        let total: Decimal
    }

    var totalAmount: Decimal {
        transactions.reduce(0) { $0 + $1.amount }
    }

    var groupedTransactions: [TransactionGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }

        return grouped.map { date, transactions in
            let sorted = transactions.sorted { $0.date > $1.date }
            let total = transactions.reduce(0) { $0 + $1.amount }
            return TransactionGroup(date: date, transactions: sorted, total: total)
        }
        .sorted { $0.date > $1.date }
    }
}

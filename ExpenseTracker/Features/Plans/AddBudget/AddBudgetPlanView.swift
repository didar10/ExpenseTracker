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
    @State private var showingCategoryPicker = false

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: AppSpacing.xLarge) {
                        previewCard
                        categorySection
                        amountSection
                        periodSection
                    }
                    .padding(AppSpacing.large)
                    .padding(.bottom, AppSpacing.huge + AppSpacing.xxxLarge)
                }
            }

            saveBar
        }
        .sheet(isPresented: $showingCategoryPicker) {
            CategoryPickerSheet(
                categories: categories,
                selectedCategory: selectedCategory,
                onSelect: { category in
                    selectedCategory = category
                }
            )
            .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - Subviews
private extension AddBudgetPlanView {

    var header: some View {
        ZStack {
            AppText(AppString.newBudget, style: .section)

            HStack {
                ToolbarIconButton(icon: "xmark", isOutlined: true) {
                    dismiss()
                }

                Spacer()
            }
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.small)
    }

    var previewCard: some View {
        VStack(spacing: AppSpacing.large) {
            AppText(
                AppString.preview.uppercased(),
                style: .microCaption,
                color: AppColor.textSecondary
            )
            .tracking(AppSpacing.hairline)

            HStack(spacing: AppSpacing.medium) {
                if let category = selectedCategory {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                            .fill(Color(hex: category.colorHex).opacity(0.2))
                            .frame(width: AppSize.iconLarge, height: AppSize.iconLarge)

                        Image(systemName: category.icon)
                            .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                            .foregroundStyle(Color(hex: category.colorHex))
                    }

                    AppText(category.name, style: .bodySmall)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                            .fill(Color(.systemGray4).opacity(0.2))
                            .frame(width: AppSize.iconLarge, height: AppSize.iconLarge)

                        Image(systemName: "minus")
                            .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                            .foregroundStyle(AppColor.textSecondary)
                    }

                    AppText(AppString.noCategory, style: .bodySmall, color: AppColor.textSecondary)
                }

                Spacer()

                if !amount.isEmpty, let value = Decimal(string: amount.replacingOccurrences(of: ",", with: ".")), value > 0 {
                    Text(value.formatted(.currency(code: AppString.currencyCode)))
                        .font(.app(.caption))
                        .fontDesign(.rounded)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            .padding(AppSpacing.large)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .fill(AppColor.cardBackground)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xLarge)
        .padding(.horizontal, AppSpacing.large)
        .card(cornerRadius: AppRadius.xLarge)
    }

    var categorySection: some View {
        CategoryFormSectionView(title: AppString.category.uppercased()) {
            Button {
                showingCategoryPicker = true
            } label: {
                HStack {
                    if let category = selectedCategory {
                        HStack(spacing: AppSpacing.small) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: category.colorHex).opacity(0.2))
                                    .frame(width: 28, height: 28)

                                Image(systemName: category.icon)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color(hex: category.colorHex))
                            }

                            AppText(category.name, style: .body)
                        }
                    } else {
                        AppText(AppString.chooseCategory, style: .body, color: AppColor.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(AppSpacing.large)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .fill(AppColor.cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .strokeBorder(
                            AppColor.textPrimary.opacity(0.15),
                            lineWidth: AppSpacing.hairline
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    var amountSection: some View {
        CategoryFormSectionView(title: AppString.limit.uppercased()) {
            HStack {
                TextField("0", text: $amount)
                    .font(.system(size: 28, weight: .bold))
                    .fontDesign(.rounded)
                    .keyboardType(.decimalPad)

                AppText(AppString.currencySymbol, style: .title, color: AppColor.textSecondary)
            }
            .padding(AppSpacing.large)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .fill(AppColor.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .strokeBorder(
                        AppColor.textPrimary.opacity(0.15),
                        lineWidth: AppSpacing.hairline
                    )
            )
        }
    }

    var periodSection: some View {
        CategoryFormSectionView(title: AppString.period.uppercased()) {
            HStack(spacing: AppSpacing.medium) {
                ForEach(BudgetPeriod.allCases, id: \.self) { period in
                    Button {
                        selectedPeriod = period
                    } label: {
                        Text(period.rawValue)
                            .font(.app(.bodySmall))
                            .foregroundStyle(
                                selectedPeriod == period
                                    ? Color(.systemBackground)
                                    : AppColor.textPrimary
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.medium)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                                    .fill(selectedPeriod == period ? AppColor.textPrimary : AppColor.cardBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                                    .strokeBorder(
                                        AppColor.textPrimary.opacity(0.15),
                                        lineWidth: AppSpacing.hairline
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    var saveBar: some View {
        CategorySaveButtonView(
            title: saveButtonTitle,
            isEnabled: canSave,
            action: savePlan
        )
        .padding(.horizontal, AppSpacing.large)
        .padding(.top, AppSpacing.medium)
        .padding(.bottom, AppSpacing.large)
        .background(
            AppColor.background
                .ignoresSafeArea(edges: .bottom)
        )
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

    var saveButtonTitle: String {
        if selectedCategory == nil {
            return AppString.chooseCategory
        }
        let cleanedAmount = amount.replacingOccurrences(of: ",", with: ".")
        if amount.isEmpty || Decimal(string: cleanedAmount) == nil || Decimal(string: cleanedAmount)! <= 0 {
            return AppString.enterAmount
        }
        return AppString.createBudget
    }

    func savePlan() {
        guard let category = selectedCategory else { return }
        let cleanedAmount = amount.replacingOccurrences(of: ",", with: ".")
        guard let amountValue = Decimal(string: cleanedAmount), amountValue > 0 else { return }

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

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

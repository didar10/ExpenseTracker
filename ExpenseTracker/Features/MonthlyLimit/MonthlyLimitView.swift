//
//  MonthlyLimitView.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import SwiftUI

/// Настройка общего лимита трат на месяц
struct MonthlyLimitView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: MonthlyLimitViewModel

    @FocusState private var isAmountFocused: Bool

    // MARK: - Init

    init(limitStore: MonthlyLimitStore) {
        _viewModel = StateObject(wrappedValue: MonthlyLimitViewModel(limitStore: limitStore))
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            SheetHeaderView(title: AppString.monthlyLimitTitle, onClose: { dismiss() })

            VStack(alignment: .leading, spacing: AppSpacing.large) {
                AppText(AppString.monthlyLimitDescription, style: .caption, color: AppColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                amountField

                if let perDayHint = viewModel.perDayHint {
                    AppText(perDayHint, style: .microCaption, color: AppColor.textSecondary)
                        .padding(.horizontal, AppSpacing.xSmall)
                        .transition(.opacity)
                }

                Spacer(minLength: 0)

                actions
            }
            .padding(AppSpacing.large)
            .animation(.snappy(duration: Constants.hintDuration), value: viewModel.perDayHint)
        }
        .background(AppColor.background)
        .onAppear { isAmountFocused = true }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Subviews

private extension MonthlyLimitView {

    var amountField: some View {
        HStack {
            TextField(AppString.amountPlaceholder, text: $viewModel.amountText)
                .font(.app(.title))
                .fontDesign(.rounded)
                .keyboardType(.decimalPad)
                .focused($isAmountFocused)

            AppText(AppString.currencySymbol, style: .title, color: AppColor.textSecondary)
        }
        .padding(AppSpacing.large)
        .cardShadow(cornerRadius: AppRadius.card)
    }

    var actions: some View {
        VStack(spacing: AppSpacing.medium) {
            PrimaryActionButton(
                title: viewModel.saveButtonTitle,
                isEnabled: viewModel.canSave,
                action: save
            )

            if viewModel.hasLimit {
                Button(role: .destructive, action: removeLimit) {
                    AppText(AppString.removeMonthlyLimit, style: .caption, color: AppColor.expense)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.small)
                }
                .buttonStyle(PressableScaleButtonStyle())
            }
        }
    }
}

// MARK: - Actions

private extension MonthlyLimitView {

    func save() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        viewModel.save()
        dismiss()
    }

    func removeLimit() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        viewModel.removeLimit()
        dismiss()
    }
}

// MARK: - Constants

private extension MonthlyLimitView {

    enum Constants {
        static let hintDuration: Double = 0.2
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            MonthlyLimitView(limitStore: MonthlyLimitStore(defaults: UserDefaults(suiteName: "preview") ?? .standard))
        }
}

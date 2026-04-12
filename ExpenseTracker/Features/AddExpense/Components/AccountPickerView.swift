//
//  AccountPickerView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI
import SwiftData

struct AccountPickerView: View {

    // MARK: - Properties

    @Binding var selectedAccount: Account?
    let transactionAmount: String
    let transactionType: TransactionType
    @Binding var showingAccountPicker: Bool

    @Query(sort: \Account.createdAt, order: .forward) private var accounts: [Account]

    // MARK: - Computed Properties

    private var amountDecimal: Decimal {
        Decimal(string: transactionAmount.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private var predictedBalance: Decimal? {
        guard let account = selectedAccount, amountDecimal > 0 else { return nil }

        if transactionType == .income {
            return account.currentBalance + amountDecimal
        } else {
            return account.currentBalance - amountDecimal
        }
    }

    // MARK: - Body

    var body: some View {
        Button {
            showingAccountPicker = true
        } label: {
            HStack(spacing: 10) {
                if let account = selectedAccount {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(account.swiftUIColor.opacity(0.2))
                            .frame(width: 36, height: 36)

                        Image(systemName: account.icon)
                            .font(.system(size: 15))
                            .foregroundStyle(account.swiftUIColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(account.name)
                            .font(.app(.microCaption))
                            .foregroundStyle(AppColor.textSecondary)

                        if let predicted = predictedBalance, amountDecimal > 0 {
                            Text(predicted.formatted(.currency(code: AppString.currencyCode)))
                                .font(.app(.bodySmall))
                                .fontDesign(.rounded)
                                .foregroundStyle(transactionType == .income ? AppColor.income : AppColor.expense)
                        } else {
                            Text(account.currentBalance.formatted(.currency(code: AppString.currencyCode)))
                                .font(.app(.bodySmall))
                                .fontDesign(.rounded)
                                .foregroundStyle(AppColor.textPrimary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    AppImage.creditcard
                        .foregroundStyle(AppColor.textSecondary)
                        .font(.system(size: 18))

                    Text(AppString.chooseAccount)
                        .font(.app(.bodySmaller))
                        .foregroundStyle(AppColor.textSecondary)

                    Spacer()
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 60)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppColor.cardBackground)
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            if selectedAccount == nil {
                selectedAccount = accounts.first { $0.isDefault } ?? accounts.first
            }
        }
    }
}

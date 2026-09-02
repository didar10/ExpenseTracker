//
//  AccountRowView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.04.2026.
//

import SwiftUI

struct AccountRowView: View {

    // MARK: - Properties

    let account: Account
    let isEditing: Bool
    /// Счет, по которому сейчас отфильтрованы данные: отмечается галочкой
    var isSelected: Bool = false
    let onEdit: () -> Void
    let onDelete: () -> Void

    // MARK: - Computed Properties

    private var balance: Decimal {
        account.currentBalance
    }

    private var balanceText: String {
        balance.formatted(.currency(code: AppString.currencyCode))
    }

    /// Уход счета в минус — единственное, что подсвечивается цветом в строке
    private var balanceColor: Color {
        balance < 0 ? AppColor.expense : AppColor.textSecondary
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            iconBadge

            title

            Spacer(minLength: AppSpacing.small)

            trailingAccessories
        }
        .padding(.vertical, AppSpacing.small)
        .contentShape(Rectangle())
        .accessibilityElement(children: isEditing ? .contain : .combine)
        .accessibilityValue(isEditing ? "" : balanceText)
        .accessibilityAddTraits(isSelected && !isEditing ? .isSelected : [])
    }
}

// MARK: - Subviews
private extension AccountRowView {

    var iconBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .fill(account.swiftUIColor.opacity(0.2))
                .frame(width: AppSize.iconMedium, height: AppSize.iconMedium)

            Image(systemName: account.icon)
                .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                .foregroundStyle(account.swiftUIColor)
        }
        .accessibilityHidden(true)
    }

    var title: some View {
        HStack(spacing: AppSpacing.xSmall) {
            AppText(account.name, style: .bodySmall)
                .lineLimit(1)
                .truncationMode(.tail)

            if account.isDefault {
                AppImage.starFill
                    .font(.system(size: AppSize.glyphTiny))
                    .foregroundStyle(AppColor.highlight)
                    .accessibilityLabel(AppString.defaultAccount)
                    .layoutPriority(1)
            }
        }
    }

    @ViewBuilder
    var trailingAccessories: some View {
        if isEditing {
            HStack(spacing: AppSpacing.small) {
                editButton
                deleteButton
            }
        } else {
            HStack(spacing: AppSpacing.small) {
                // Сумма важнее названия: при нехватке места сокращается название,
                // а баланс остается читаемым целиком
                Text(balanceText)
                    .font(.app(.caption))
                    .fontDesign(.rounded)
                    .monospacedDigit()
                    .foregroundStyle(balanceColor)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .layoutPriority(1)

                // Место под галочку занято всегда: суммы в списке не разъезжаются
                // при переключении выбранного счета
                AppImage.checkmark
                    .font(.system(size: AppSize.glyphMedium, weight: .semibold))
                    .foregroundStyle(AppColor.accent)
                    .opacity(isSelected ? 1 : 0)
                    .accessibilityHidden(true)
            }
        }
    }

    var editButton: some View {
        Button(action: onEdit) {
            AppImage.pencil
                .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: AppSize.iconLarge, height: AppSize.iconLarge)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .fill(AppColor.accent.opacity(0.15))
                )
        }
        .buttonStyle(PressableScaleButtonStyle())
        .accessibilityLabel(AppString.edit)
    }

    var deleteButton: some View {
        Button(action: onDelete) {
            AppImage.trash
                .font(.system(size: AppSize.glyphLarge, weight: .semibold))
                .foregroundStyle(AppColor.expense)
                .frame(width: AppSize.iconLarge, height: AppSize.iconLarge)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .fill(AppColor.expense.opacity(0.15))
                )
        }
        .buttonStyle(PressableScaleButtonStyle())
        .accessibilityLabel(AppString.delete)
    }
}

#Preview {
    let account = Account(name: "Основной счет", icon: "creditcard.fill", color: "blue", isDefault: true)

    return VStack(spacing: 0) {
        AccountRowView(account: account, isEditing: false, isSelected: true, onEdit: {}, onDelete: {})

        Divider()

        AccountRowView(
            account: Account(name: "Кредитная карта Kaspi Gold", icon: "creditcard.fill", color: "red"),
            isEditing: false,
            onEdit: {},
            onDelete: {}
        )

        Divider()

        AccountRowView(account: account, isEditing: true, onEdit: {}, onDelete: {})
    }
    .padding(AppSpacing.large)
    .card(cornerRadius: AppRadius.xLarge)
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

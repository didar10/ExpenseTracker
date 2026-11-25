import SwiftUI

struct EmptyAccountsView: View {
    let onAddTap: () -> Void

    var body: some View {
        Card(style: .dashed, padding: nil) {
            VStack(spacing: .zero) {
                Image(systemName: "wallet.bifold")
                    .font(.system(size: DS.Size.iconAdd, weight: .semibold))
                    .foregroundStyle(DS.Color.onAccent)
                    .frame(width: DS.AccountList.emptyIconSize, height: DS.AccountList.emptyIconSize)
                    .background(DS.Color.accent, in: RoundedRectangle(cornerRadius: DS.AccountList.emptyIconRadius))
                    .brutalBorder(radius: DS.AccountList.emptyIconRadius)
                    .accessibilityHidden(true)

                Text(AppString.noAccounts)
                    .font(DS.Font.dialogTitle)
                    .foregroundStyle(DS.Color.ink)
                    .padding(.top, DS.Spacing.lg)

                Text(AppString.addAccountHint)
                    .font(DS.Font.bodySmall)
                    .foregroundStyle(DS.Color.ink2)
                    .multilineTextAlignment(.center)
                    .padding(.top, DS.Spacing.sm)

                PrimaryButton(title: AppString.addAccount, icon: DS.Icon.plus, action: onAddTap)
                    .padding(.top, DS.Spacing.lg)
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.vertical, DS.AccountList.emptyVerticalPadding)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview("Пусто · светлая") {
    EmptyAccountsView(onAddTap: {}).padding(DS.Spacing.xl).background(DS.Color.bg)
}
#Preview("Пусто · темная") {
    EmptyAccountsView(onAddTap: {}).padding(DS.Spacing.xl).background(DS.Color.bg).preferredColorScheme(.dark)
}

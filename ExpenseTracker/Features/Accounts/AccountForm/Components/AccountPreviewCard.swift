import SwiftUI

/// Живое превью начального баланса. Тень у этой карточки явно задана макетом формы.
struct AccountPreviewCard: View {
    let name: String
    let amount: Decimal
    let icon: String
    let color: DS.AccountColor

    @ScaledMetric(relativeTo: .title) private var height = DS.AccountForm.previewHeight

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            HStack(alignment: .top, spacing: DS.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: DS.Size.iconM, weight: .semibold))
                    .foregroundStyle(DS.Color.ink)
                    .frame(width: DS.AccountForm.iconSize, height: DS.AccountForm.iconSize)
                    .background(DS.Color.surface, in: RoundedRectangle(cornerRadius: DS.AccountForm.iconRadius))
                    .brutalBorder(radius: DS.AccountForm.iconRadius)
                    .accessibilityHidden(true)
                Spacer(minLength: .zero)
                Text(name.isEmpty ? AppString.newAccount : name)
                    .dsLabel(color: color.foreground)
                    .lineLimit(1)
                    .minimumScaleFactor(DS.AccountForm.minimumScale)
            }
            Spacer(minLength: DS.Spacing.sm)
            Text(MoneyFormat.money(amount))
                .font(DS.Font.amountM)
                .foregroundStyle(color.foreground)
                .lineLimit(1)
                .minimumScaleFactor(DS.AccountForm.minimumScale)
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.vertical, DS.AccountForm.previewVerticalPadding)
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(color.color, in: RoundedRectangle(cornerRadius: DS.AccountForm.previewRadius))
        .brutalBorder(radius: DS.AccountForm.previewRadius)
        .hardShadow()
        .accessibilityElement(children: .combine)
    }
}

#Preview("Светлая") {
    DSPreviewGallery {
        AccountPreviewCard(name: "", amount: 0, icon: AccountKind.card.icon, color: .yellow)
        AccountPreviewCard(name: "Наличные", amount: 32_000, icon: AccountKind.cash.icon, color: .green)
    }
}
#Preview("Темная") {
    DSPreviewGallery {
        AccountPreviewCard(name: "", amount: 0, icon: AccountKind.card.icon, color: .yellow)
        AccountPreviewCard(name: "Наличные", amount: 32_000, icon: AccountKind.cash.icon, color: .green)
    }.preferredColorScheme(.dark)
}

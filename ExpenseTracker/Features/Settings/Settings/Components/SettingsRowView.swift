import SwiftUI

struct SettingsRowView: View {
    let icon: Image
    var iconColor = DS.Color.surface
    let title: String
    var subtitle: String?
    var value: String?
    var isDestructive = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.md) {
                SettingsIconBadge(icon: icon, fill: iconColor, isDestructive: isDestructive)

                VStack(alignment: .leading, spacing: DS.Settings.subtitleSpacing) {
                    Text(title)
                        .font(DS.Font.bodyBold)
                        .foregroundStyle(isDestructive ? DS.Color.danger : DS.Color.ink)
                    if let subtitle {
                        Text(subtitle)
                            .font(DS.Font.caption)
                            .foregroundStyle(DS.Color.ink2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

                if let value {
                    Text(value)
                        .font(DS.Font.moneySmall)
                        .foregroundStyle(DS.Color.ink2)
                }
                if !isDestructive {
                    DS.Icon.chevronRight
                        .font(.system(size: DS.Size.iconXS, weight: .semibold))
                        .foregroundStyle(DS.Color.ink)
                        .accessibilityHidden(true)
                }
            }
            .settingsRowInsets()
            .contentShape(Rectangle())
        }
        .buttonStyle(.outlineClickSegment)
    }
}

struct SettingsIconBadge: View {
    let icon: Image
    let fill: Color
    var isDestructive = false
    var foreground = DS.Color.ink

    var body: some View {
        let size = CategoryTile.Size.medium
        let color = isDestructive ? DS.Color.dangerFill : foreground
        icon
            .font(.system(size: size.iconSize, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: size.side, height: size.side)
            .background(fill, in: RoundedRectangle(cornerRadius: size.radius))
            .brutalBorder(radius: size.radius, color: isDestructive ? DS.Color.dangerFill : DS.Color.ink)
            .accessibilityHidden(true)
    }
}

extension View {
    func settingsRowInsets() -> some View {
        padding(.leading, DS.Spacing.md)
            .padding(.trailing, DS.Settings.rowTrailing)
            .padding(.vertical, DS.Spacing.sm)
            .frame(minHeight: DS.Settings.rowHeight)
    }
}

#Preview("Строки · светлая") { settingsRowsPreview }
#Preview("Строки · тёмная") { settingsRowsPreview.preferredColorScheme(.dark) }

@MainActor
private var settingsRowsPreview: some View {
    SettingsSectionView(title: AppString.general) {
        SettingsRowView(icon: Image(systemName: "wallet.bifold"), iconColor: DS.CategoryColor.green.color,
                        title: AppString.accounts, value: "3") {}
        ListDivider()
        SettingsRowView(icon: DS.Icon.trash, iconColor: DS.Color.accountRed,
                        title: AppString.deleteAllData, subtitle: AppString.settingsDeleteDataSubtitle, isDestructive: true) {}
    }
    .padding(DS.Spacing.xl)
    .background(DS.Color.bg)
}

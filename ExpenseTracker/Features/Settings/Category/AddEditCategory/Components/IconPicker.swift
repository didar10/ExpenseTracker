import SwiftUI

struct IconPicker: View {
    @Binding var selection: String
    var originalIcon: String?

    private static let icons = [
        "basket", "cup.and.saucer", "bag", "car", "house", "heart",
        "gamecontroller", "iphone", "gift", "airplane", "book", "dumbbell",
        "pawprint", "tshirt", "banknote", "briefcase", "chart.bar", "tag"
    ]

    private var options: [String] {
        var icons = Self.icons
        if let originalIcon, !icons.contains(originalIcon) {
            let outline = originalIcon.replacingOccurrences(of: ".fill", with: "")
            icons[icons.firstIndex(of: outline) ?? icons.index(before: icons.endIndex)] = originalIcon
        }
        return icons
    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.sm), count: DS.AccountForm.paletteColumns), spacing: DS.Spacing.sm) {
            ForEach(options, id: \.self) { icon in
                let selected = icon == selection
                Button { selection = icon } label: {
                    Image(systemName: icon)
                        .font(.system(size: DS.Size.iconL, weight: .semibold))
                        .foregroundStyle(selected ? DS.Color.onAccent : DS.Color.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: DS.CategoryForm.iconCellHeight)
                        .background(selected ? DS.Color.accent : DS.Color.surface,
                                    in: RoundedRectangle(cornerRadius: DS.CategoryForm.iconCellRadius))
                        .brutalBorder(radius: DS.CategoryForm.iconCellRadius)
                        .hardShadow(.hardSmall, color: selected ? DS.Color.ink : .clear)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(AppString.selectIcon)
    }
}

#Preview("Светлая") { IconPicker(selection: .constant("basket")).padding(DS.Spacing.xl).background(DS.Color.bg) }
#Preview("Тёмная") {
    IconPicker(selection: .constant("cup.and.saucer")).padding(DS.Spacing.xl).background(DS.Color.bg).preferredColorScheme(.dark)
}

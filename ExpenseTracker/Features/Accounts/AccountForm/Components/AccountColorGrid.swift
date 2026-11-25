import SwiftUI

struct AccountColorGrid: View {
    @Binding var selection: String

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DS.AccountForm.paletteSpacing), count: DS.AccountForm.paletteColumns), spacing: DS.AccountForm.paletteSpacing) {
            ForEach(DS.AccountColor.allCases, id: \.self) { color in
                let selected = DS.AccountColor(name: selection) == color
                Button { selection = color.rawValue } label: {
                    RoundedRectangle(cornerRadius: DS.AccountForm.swatchRadius)
                        .fill(color.color)
                        .frame(height: DS.AccountForm.swatchHeight)
                        .brutalBorder(radius: DS.AccountForm.swatchRadius)
                        .overlay {
                            if selected {
                                RoundedRectangle(cornerRadius: DS.AccountForm.swatchRadius + DS.AccountForm.selectionGap)
                                    .stroke(DS.Color.ink, lineWidth: DS.AccountForm.selectionWidth)
                                    .padding(-DS.AccountForm.selectionGap - DS.AccountForm.selectionWidth / 2)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(color.accessibilityName)
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(AppString.color)
    }
}

#Preview("Светлая") {
    AccountColorGrid(selection: .constant("yellow")).padding(DS.Spacing.xl).background(DS.Color.bg)
}
#Preview("Темная") {
    AccountColorGrid(selection: .constant("green")).padding(DS.Spacing.xl).background(DS.Color.bg).preferredColorScheme(.dark)
}

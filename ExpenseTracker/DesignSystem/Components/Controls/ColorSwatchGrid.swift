import SwiftUI

struct ColorSwatchGrid: View {
    @Binding var selection: DS.AccountColor

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DS.AccountForm.paletteSpacing), count: DS.AccountForm.paletteColumns), spacing: DS.AccountForm.paletteSpacing) {
            ForEach(DS.AccountColor.allCases, id: \.self) { color in
                let selected = selection == color
                Button { selection = color } label: {
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
    ColorSwatchGrid(selection: .constant(.yellow)).padding(DS.Spacing.xl).background(DS.Color.bg)
}
#Preview("Темная") {
    ColorSwatchGrid(selection: .constant(.green)).padding(DS.Spacing.xl).background(DS.Color.bg).preferredColorScheme(.dark)
}

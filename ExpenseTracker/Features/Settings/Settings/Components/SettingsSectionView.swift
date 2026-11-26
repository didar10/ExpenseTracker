import SwiftUI

struct SettingsSectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text(title)
                .dsLabel()
                .padding(.horizontal, DS.Settings.labelInset)
                .accessibilityAddTraits(.isHeader)

            Card(padding: nil) {
                VStack(spacing: .zero) { content }
            }
        }
    }
}

import SwiftUI

struct EmptyCategoriesView: View {
    let onCreateTap: () -> Void

    var body: some View {
        Card(style: .dashed, padding: nil) {
            VStack(spacing: .zero) {
                Image(systemName: "tag")
                    .font(.system(size: DS.Size.iconAdd, weight: .semibold))
                    .foregroundStyle(DS.Color.onAccent)
                    .frame(width: DS.CategoryManagement.emptyIconSize, height: DS.CategoryManagement.emptyIconSize)
                    .background(DS.Color.accent, in: RoundedRectangle(cornerRadius: DS.Radius.card))
                    .brutalBorder(radius: DS.Radius.card)
                    .accessibilityHidden(true)
                Text(AppString.noCategories)
                    .font(DS.Font.dialogTitle)
                    .foregroundStyle(DS.Color.ink)
                    .padding(.top, DS.CategoryManagement.sectionSpacing)
                Text(AppString.addCategoryHint)
                    .font(DS.Font.bodySmall)
                    .foregroundStyle(DS.Color.ink2)
                    .multilineTextAlignment(.center)
                    .padding(.top, DS.Spacing.sm)
                PrimaryButton(title: AppString.createCategory, icon: DS.Icon.plus, action: onCreateTap)
                    .padding(.top, DS.Spacing.lg)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.vertical, DS.CategoryManagement.emptyVerticalPadding)
        }
    }
}

#Preview("Пусто") { EmptyCategoriesView(onCreateTap: {}).padding().background(DS.Color.bg) }
#Preview("Пусто · тёмная") {
    EmptyCategoriesView(onCreateTap: {}).padding().background(DS.Color.bg).preferredColorScheme(.dark)
}

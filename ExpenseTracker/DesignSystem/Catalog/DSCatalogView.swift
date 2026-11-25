//
//  DSCatalogView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

#if DEBUG

import SwiftUI

/// Витрина дизайн-системы: все токены с подписями. Открывается из раздела «Отладка» в Настройках
struct DSCatalogView: View {

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Spacing.xxl) {
                Text(AppString.dsCatalogTitle)
                    .font(DS.Font.screenTitle)
                    .foregroundStyle(DS.Color.ink)

                colorsSection
                categoryColorsSection
                fontsSection
                strokesAndShadowsSection
                radiiSection
                spacingSection
            }
            .padding(DS.Spacing.lg)
        }
        .background(DS.Color.bg)
    }
}

// MARK: - Subviews

private extension DSCatalogView {

    var colorsSection: some View {
        section(AppString.dsCatalogColors) {
            LazyVGrid(columns: Layout.swatchColumns, alignment: .leading, spacing: DS.Spacing.lg) {
                ForEach(Sample.colors, id: \.name) { sample in
                    swatch(sample.color, name: sample.name, value: sample.value)
                }
            }
        }
    }

    var categoryColorsSection: some View {
        section(AppString.dsCatalogCategoryColors) {
            LazyVGrid(columns: Layout.swatchColumns, alignment: .leading, spacing: DS.Spacing.lg) {
                ForEach(DS.CategoryColor.allCases, id: \.self) { category in
                    swatch(category.color, name: category.rawValue, value: Sample.categoryValues[category] ?? "")
                }
            }
        }
    }

    var fontsSection: some View {
        section(AppString.dsCatalogFonts) {
            VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                ForEach(Sample.fonts, id: \.name) { sample in
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text(verbatim: sample.text)
                            .font(sample.font)
                            .foregroundStyle(DS.Color.ink)

                        tokenCaption("\(sample.name) · \(sample.spec)")
                    }
                }

                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(verbatim: Sample.labelText)
                        .dsLabel(color: DS.Color.ink)

                    tokenCaption("label + .dsLabel() · SF Semibold 12, uppercase, 0.06em")
                }
            }
        }
    }

    var strokesAndShadowsSection: some View {
        section(AppString.dsCatalogStrokesAndShadows) {
            LazyVGrid(columns: Layout.boxColumns, alignment: .leading, spacing: DS.Spacing.xl) {
                box(caption: "1.5 · hard 3×3 · card") {
                    tile(radius: DS.Radius.card).hardShadow()
                }
                box(caption: "1.5 · hardSmall 2×2 · control") {
                    tile(radius: DS.Radius.control).hardShadow(.hardSmall)
                }
                box(caption: "1.5 · без тени · card") {
                    tile(radius: DS.Radius.card)
                }
                box(caption: "pressed 2.5 · control") {
                    tile(radius: DS.Radius.control, lineWidth: DS.Stroke.pressed)
                }
                box(caption: "accent · hard") {
                    tile(radius: DS.Radius.control, fill: DS.Color.accent).hardShadow()
                }
                box(caption: "danger · hard danger") {
                    tile(radius: DS.Radius.control, fill: DS.Color.danger).hardShadow(color: DS.Color.danger)
                }
            }
        }
    }

    var radiiSection: some View {
        section(AppString.dsCatalogRadii) {
            LazyVGrid(columns: Layout.boxColumns, alignment: .leading, spacing: DS.Spacing.xl) {
                ForEach(Sample.radii, id: \.name) { sample in
                    box(caption: "\(sample.name) · \(Int(sample.value))") {
                        tile(radius: sample.value)
                    }
                }
            }
        }
    }

    var spacingSection: some View {
        section(AppString.dsCatalogSpacing) {
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                ForEach(Sample.spacing, id: \.name) { sample in
                    HStack(spacing: DS.Spacing.md) {
                        Rectangle()
                            .fill(DS.Color.accent)
                            .frame(width: sample.value, height: DS.Spacing.lg)
                            .brutalBorder(radius: .zero, lineWidth: DS.Stroke.regular)

                        tokenCaption("\(sample.name) · \(Int(sample.value))")
                    }
                }
            }
        }
    }

    // MARK: - Building Blocks

    func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text(title)
                .dsLabel()

            content()
        }
    }

    func swatch(_ color: Color, name: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            RoundedRectangle(cornerRadius: DS.Radius.control)
                .fill(color)
                .frame(height: Layout.swatchHeight)
                .brutalBorder(radius: DS.Radius.control)

            Text(verbatim: name)
                .font(DS.Font.bodyBold)
                .foregroundStyle(DS.Color.ink)

            tokenCaption(value)
        }
        .accessibilityElement(children: .combine)
    }

    func box<Content: View>(caption: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            content()
            tokenCaption(caption)
        }
    }

    func tile(radius: CGFloat, lineWidth: CGFloat = DS.Stroke.regular, fill: Color = DS.Color.surface) -> some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(fill)
            .frame(height: Layout.tileHeight)
            .brutalBorder(radius: radius, lineWidth: lineWidth)
    }

    func tokenCaption(_ text: String) -> some View {
        Text(verbatim: text)
            .font(DS.Font.moneySmall)
            .foregroundStyle(DS.Color.ink2)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Layout

private extension DSCatalogView {

    /// Размеры образцов — только для витрины, в экранах не используются
    enum Layout {
        static let swatchHeight: CGFloat = 56
        static let tileHeight: CGFloat = 64
        static let swatchMinWidth: CGFloat = 96
        static let boxMinWidth: CGFloat = 140

        static let swatchColumns = [GridItem(.adaptive(minimum: swatchMinWidth), spacing: DS.Spacing.lg, alignment: .top)]
        static let boxColumns = [GridItem(.adaptive(minimum: boxMinWidth), spacing: DS.Spacing.xl, alignment: .top)]
    }
}

// MARK: - Samples

/// Подписи образцов — технические имена токенов, поэтому не локализуются
private enum Sample {

    struct ColorSample {
        let name: String
        let color: Color
        let value: String
    }

    struct FontSample {
        let name: String
        let font: Font
        let spec: String
        let text: String
    }

    struct MetricSample {
        let name: String
        let value: CGFloat
    }

    static let amount = "975 050 ₸"
    static let title = "Бюджеты"
    static let text = "Продукты на неделю"
    static let money = "−4 850 · +480 000 ₸"
    static let labelText = "Сегодня · Категории"

    static let colors = [
        ColorSample(name: "bg", color: DS.Color.bg, value: "#F4F2EE / #121212"),
        ColorSample(name: "surface", color: DS.Color.surface, value: "#FFFFFF / #1C1C1E"),
        ColorSample(name: "ink", color: DS.Color.ink, value: "#111111 / #F2F2F2"),
        ColorSample(name: "ink2", color: DS.Color.ink2, value: "#6B6B70 / #A1A1A6"),
        ColorSample(name: "line", color: DS.Color.line, value: "ink 12% / 14%"),
        ColorSample(name: "accent", color: DS.Color.accent, value: "#FFD60A"),
        ColorSample(name: "onAccent", color: DS.Color.onAccent, value: "#111111"),
        ColorSample(name: "income", color: DS.Color.income, value: "#1B7F3B / #5BD37A"),
        ColorSample(name: "danger", color: DS.Color.danger, value: "#C4281C / #FF6B5E")
    ]

    static let categoryValues: [DS.CategoryColor: String] = [
        .green: "#8EE3A1 / #2E7D46",
        .blue: "#9CC8FF / #2F5E9E",
        .purple: "#D4B5FF / #6544A8",
        .orange: "#FFC78A / #9A5A12",
        .pink: "#FFB3CF / #9C3361"
    ]

    static let fonts = [
        FontSample(name: "screenTitle", font: DS.Font.screenTitle, spec: "Unbounded Bold 28", text: title),
        FontSample(name: "sheetTitle", font: DS.Font.sheetTitle, spec: "Unbounded Bold 22", text: title),
        FontSample(name: "amountXL", font: DS.Font.amountXL, spec: "Unbounded Bold 48", text: amount),
        FontSample(name: "amountL", font: DS.Font.amountL, spec: "Unbounded Bold 40", text: amount),
        FontSample(name: "body", font: DS.Font.body, spec: "SF 16", text: text),
        FontSample(name: "bodyBold", font: DS.Font.bodyBold, spec: "SF Semibold 16", text: text),
        FontSample(name: "caption", font: DS.Font.caption, spec: "SF 13", text: text),
        FontSample(name: "money", font: DS.Font.money, spec: "JetBrains Mono Bold 15", text: money),
        FontSample(name: "moneySmall", font: DS.Font.moneySmall, spec: "JetBrains Mono Medium 12", text: money)
    ]

    static let radii = [
        MetricSample(name: "control", value: DS.Radius.control),
        MetricSample(name: "card", value: DS.Radius.card),
        MetricSample(name: "tabBar", value: DS.Radius.tabBar),
        MetricSample(name: "sheet", value: DS.Radius.sheet)
    ]

    static let spacing = [
        MetricSample(name: "xs", value: DS.Spacing.xs),
        MetricSample(name: "sm", value: DS.Spacing.sm),
        MetricSample(name: "md", value: DS.Spacing.md),
        MetricSample(name: "lg", value: DS.Spacing.lg),
        MetricSample(name: "xl", value: DS.Spacing.xl),
        MetricSample(name: "xxl", value: DS.Spacing.xxl)
    ]
}

// MARK: - Previews

#Preview("Светлая") {
    DSCatalogView()
        .preferredColorScheme(.light)
}

#Preview("Темная") {
    DSCatalogView()
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type xxxLarge") {
    DSCatalogView()
        .environment(\.dynamicTypeSize, .xxxLarge)
}

#endif

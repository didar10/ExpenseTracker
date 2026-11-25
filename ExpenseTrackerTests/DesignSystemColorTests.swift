//
//  DesignSystemColorTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 25.11.2026.
//

import Testing
import UIKit
@testable import ExpenseTracker

/// Цвета из Asset Catalog совпадают с `Design/html/_Tokens.html` и `MainDark.html`.
/// Отсутствующий ассет SwiftUI молча рисует прозрачным — тест ловит опечатки в именах
@MainActor
struct DesignSystemColorTests {

    struct Spec: CustomTestStringConvertible, Sendable {
        let asset: String
        let light: String
        let dark: String
        var lightAlpha: CGFloat = 1
        var darkAlpha: CGFloat = 1

        var testDescription: String { asset }
    }

    nonisolated static let specs: [Spec] = [
        Spec(asset: DS.Color.Name.bg, light: "F4F2EE", dark: "121212"),
        Spec(asset: DS.Color.Name.surface, light: "FFFFFF", dark: "1C1C1E"),
        Spec(asset: DS.Color.Name.ink, light: "111111", dark: "F2F2F2"),
        Spec(asset: DS.Color.Name.ink2, light: "6B6B70", dark: "A1A1A6"),
        Spec(asset: DS.Color.Name.line, light: "111111", dark: "F2F2F2", lightAlpha: 0.12, darkAlpha: 0.14),
        Spec(asset: DS.Color.Name.accent, light: "FFD60A", dark: "FFD60A"),
        Spec(asset: DS.Color.Name.onAccent, light: "111111", dark: "111111"),
        Spec(asset: DS.Color.Name.income, light: "1B7F3B", dark: "5BD37A"),
        Spec(asset: DS.Color.Name.danger, light: "C4281C", dark: "FF6B5E"),
        Spec(asset: DS.Color.Name.overStripeStrong, light: "C4281C", dark: "C4281C"),
        Spec(asset: DS.Color.Name.overStripeSoft, light: "FF8A7E", dark: "FF8A7E"),
        Spec(asset: DS.Color.Name.scrim, light: "111111", dark: "000000", lightAlpha: 0.35, darkAlpha: 0.35),
        Spec(asset: DS.Color.Name.dangerFill, light: "C4281C", dark: "C4281C"),
        Spec(asset: DS.Color.Name.onDanger, light: "FFFFFF", dark: "FFFFFF"),
        Spec(asset: DS.Color.Name.grabber, light: "C9C5BC", dark: "48484A"),
        Spec(asset: DS.Color.Name.noCategory, light: "E6E3DC", dark: "3A3A3C"),
        Spec(asset: DS.Color.Name.inkDisabled, light: "C3C0B8", dark: "4A4A4E"),
        Spec(asset: DS.Color.Name.onColorFill, light: "FFFFFF", dark: "FFFFFF"),
        // Темного варианта в макетах нет: подобран на шаг светлее bg
        Spec(asset: DS.Color.Name.emptyHatch, light: "E6E3DC", dark: "2A2A2C"),
        Spec(asset: DS.CategoryColor.green.assetName, light: "8EE3A1", dark: "2E7D46"),
        Spec(asset: DS.CategoryColor.blue.assetName, light: "9CC8FF", dark: "2F5E9E"),
        Spec(asset: DS.CategoryColor.purple.assetName, light: "D4B5FF", dark: "6544A8"),
        Spec(asset: DS.CategoryColor.orange.assetName, light: "FFC78A", dark: "9A5A12"),
        Spec(asset: DS.CategoryColor.pink.assetName, light: "FFB3CF", dark: "9C3361")
    ]

    // MARK: - Tests

    @Test(arguments: specs)
    func colorMatchesSpec(_ spec: Spec) throws {
        try expect(spec.asset, style: .light, hex: spec.light, alpha: spec.lightAlpha)
        try expect(spec.asset, style: .dark, hex: spec.dark, alpha: spec.darkAlpha)
    }

    @Test func everyTokenIsCovered() {
        let covered = Set(Self.specs.map(\.asset))
        let tokens = Set(DS.Color.Name.all + DS.CategoryColor.allCases.map(\.assetName))

        #expect(covered == tokens)
    }

    // MARK: - Helpers

    private func expect(_ asset: String, style: UIUserInterfaceStyle, hex: String, alpha: CGFloat) throws {
        let traits = UITraitCollection(userInterfaceStyle: style)
        let color = try #require(UIColor(named: asset, in: .main, compatibleWith: traits), "Нет ассета \(asset)")

        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, actualAlpha: CGFloat = 0
        color.resolvedColor(with: traits).getRed(&red, green: &green, blue: &blue, alpha: &actualAlpha)

        let actualHex = String(format: "%02X%02X%02X", Int((red * 255).rounded()), Int((green * 255).rounded()), Int((blue * 255).rounded()))

        #expect(actualHex == hex, "\(asset) (\(style == .dark ? "темная" : "светлая"))")
        #expect(abs(actualAlpha - alpha) < 0.005, "\(asset) (\(style == .dark ? "темная" : "светлая")): альфа")
    }
}

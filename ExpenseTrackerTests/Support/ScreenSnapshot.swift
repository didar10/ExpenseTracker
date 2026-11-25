//
//  ScreenSnapshot.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 25.11.2026.
//

import SnapshotTesting
import SwiftUI
import UIKit

/// Устройства, на которых снимается каждый экран
enum SnapshotDevice: String, CaseIterable {
    case iPhone15
    case iPhoneSE

    // MARK: - Computed Properties

    var config: ViewImageConfig {
        switch self {
        case .iPhone15:
            return ViewImageConfig(
                safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
                size: CGSize(width: 393, height: 852),
                traits: UITraitCollection(traitsFrom: [.iPhone13(.portrait), .init(displayScale: 3)])
            )
        case .iPhoneSE:
            // SE 2-го и 3-го поколения; `ViewImageConfig.iPhoneSe` в библиотеке — первое, 320 pt
            return ViewImageConfig(
                safeArea: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0),
                size: CGSize(width: 375, height: 667),
                traits: UITraitCollection(traitsFrom: [.iPhone8(.portrait), .init(displayScale: 2)])
            )
        }
    }
}

/// Светлая и темная тема
enum SnapshotTheme: String, CaseIterable {
    case light
    case dark

    // MARK: - Computed Properties

    var colorScheme: ColorScheme {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }

    var traits: UITraitCollection {
        UITraitCollection(userInterfaceStyle: self == .light ? .light : .dark)
    }
}

/// Снимает View на iPhone 15 и iPhone SE в светлой и темной теме — четыре эталона за один вызов:
///
/// ```swift
/// @Test func dashboard() {
///     assertScreenSnapshots(of: DashboardView(...).fixture(FixtureEnvironment(.sample)))
/// }
/// ```
///
/// Эталоны лежат в `__Snapshots__/<файл теста>/<тест>.<имя>-<устройство>-<тема>.png`.
/// Первый запуск записывает эталоны и падает — это ожидаемо; перезаписать: `record: .all`.
/// Эталоны зависят от версии iOS симулятора, снимать их нужно на одной и той же
@MainActor
func assertScreenSnapshots<Content: View>(
    of view: Content,
    named name: String? = nil,
    devices: [SnapshotDevice] = SnapshotDevice.allCases,
    themes: [SnapshotTheme] = SnapshotTheme.allCases,
    record: SnapshotTestingConfiguration.Record? = nil,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    for device in devices {
        for theme in themes {
            let suffix = "\(device.rawValue)-\(theme.rawValue)"

            assertSnapshot(
                of: view.environment(\.colorScheme, theme.colorScheme),
                as: .image(
                    // Мелкие различия сглаживания между запусками не считаются регрессией
                    perceptualPrecision: SnapshotPrecision.perceptual,
                    layout: .device(config: device.config),
                    // Масштаб снимка библиотека берет только из этих traits, не из конфигурации устройства
                    traits: UITraitCollection(traitsFrom: [device.config.traits, theme.traits])
                ),
                named: name.map { "\($0)-\(suffix)" } ?? suffix,
                record: record,
                fileID: fileID,
                file: filePath,
                testName: testName,
                line: line,
                column: column
            )
        }
    }
}

private enum SnapshotPrecision {
    static let perceptual: Float = 0.98
}

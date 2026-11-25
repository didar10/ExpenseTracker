//
//  ScreenSnapshotTests.swift
//  ExpenseTrackerTests
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI
import Testing
@testable import ExpenseTracker

/// Проверка самого хелпера: шрифты редизайна и обе темы попадают в снимок.
/// Снапшоты экранов добавляются по мере редизайна — по одной строке на состояние
@MainActor
@Suite(.serialized)
struct ScreenSnapshotTests {

    @Test func fontSpecimen() {
        assertScreenSnapshots(of: FontSpecimenView())
    }
}

// MARK: - Specimen

/// Образец всех начертаний; размеры и цвета — только для этого теста
private struct FontSpecimenView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(DS.FontName.allCases, id: \.self) { font in
                Text("Бюджет 1 234 567 ₸")
                    .font(.custom(font.rawValue, size: 22))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .foregroundStyle(.primary)
        .background(Color(uiColor: .systemBackground))
    }
}

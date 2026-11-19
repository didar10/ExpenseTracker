//
//  SettingsRouteView.swift
//  ExpenseTracker
//
//  Created by Didar on 23.08.2026.
//

import SwiftUI

/// Собирает экран по маршруту настроек вместе с его параметрами показа
struct SettingsRouteView: View {

    // MARK: - Properties

    let route: SettingsRoute

    // MARK: - Body

    var body: some View {
        switch route {
        case .categories:
            CategoriesListView()
                .settingsSheetPresentation()

        case .privacyPolicy:
            LegalDocumentView(document: .privacyPolicy)
                .settingsSheetPresentation()

        case .helpSupport:
            HelpSupportView()
                .settingsSheetPresentation()

        case .termsOfService:
            LegalDocumentView(document: .termsOfService)
                .settingsSheetPresentation()
        }
    }
}

// MARK: - Presentation

private extension View {

    func settingsSheetPresentation() -> some View {
        presentationDetents([.large])
            .presentationDragIndicator(.hidden)
    }
}

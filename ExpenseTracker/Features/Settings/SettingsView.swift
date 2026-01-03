//
//  SettingsView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI

struct SettingsView: View {

    var body: some View {
        NavigationStack {
            List {

                // MARK: - Основные настройки
                NavigationLink {
                    CategoriesListView()
                } label: {
                    Label("Категории", systemImage: "square.grid.2x2")
                }

                NavigationLink {
                    PlansView()
                } label: {
                    Label("Валюта по умолчанию", systemImage: "dollarsign.circle")
                }

                // MARK: - Информация
                NavigationLink {
                    PlansView()
                } label: {
                    Label("Политика конфиденциальности", systemImage: "hand.raised.fill")
                }

                NavigationLink {
                    PlansView()
                } label: {
                    Label("Помощь и поддержка", systemImage: "questionmark.circle")
                }

                NavigationLink {
                    PlansView()
                } label: {
                    Label("Условия использования", systemImage: "doc.text")
                }
            }
            .navigationTitle("Настройки")
        }
    }
}




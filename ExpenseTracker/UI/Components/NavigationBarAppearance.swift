//
//  NavigationBarAppearance.swift
//  ExpenseTracker
//
//  Created by Didar on 04.01.2026.
//

import UIKit

enum NavigationBarAppearance {

    static func setup() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground

        appearance.titleTextAttributes = [
            .font: UIFont(name: "Montserrat-SemiBold", size: 18)!,
            .foregroundColor: UIColor.label
        ]

        appearance.largeTitleTextAttributes = [
            .font: UIFont(name: "Montserrat-Bold", size: 32)!,
            .foregroundColor: UIColor.label
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}


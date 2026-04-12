//
//  FormSection.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI

struct FormSection<Content: View>: View {

    // MARK: - Properties

    let title: String
    @ViewBuilder let content: Content

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                AppText(title, style: .caption)
                    .color(AppColor.textSecondary)
                    .padding(.horizontal, 4)
            }

            VStack(spacing: 0) {
                content
            }
            .padding(12)
            .card(cornerRadius: 12)
        }
    }
}

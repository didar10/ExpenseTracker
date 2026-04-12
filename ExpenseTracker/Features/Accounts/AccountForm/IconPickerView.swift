//
//  IconPickerView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI

struct IconPickerView: View {

    // MARK: - Properties

    @Binding var selectedIcon: String
    let onSelect: (String) -> Void

    private let icons = [
        "creditcard.fill",
        "wallet.pass.fill",
        "banknote.fill",
        "tengesign.circle.fill",
        "building.columns.fill",
        "briefcase.fill"
    ]

    // MARK: - Body

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(icons, id: \.self) { icon in
                    Button {
                        selectedIcon = icon
                        onSelect(icon)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(selectedIcon == icon ? AppColor.accent.opacity(0.2) : AppColor.secondaryBackground)
                                .frame(width: 44, height: 44)

                            Image(systemName: icon)
                                .font(.system(size: 20))
                                .foregroundStyle(selectedIcon == icon ? AppColor.accent : AppColor.textSecondary)
                        }
                    }
                }
            }
        }
    }
}

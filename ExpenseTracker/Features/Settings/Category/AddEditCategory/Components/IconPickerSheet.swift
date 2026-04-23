//
//  IconPickerSheet.swift
//  ExpenseTracker
//
//  Created by Didar on 22.01.2026.
//

import SwiftUI

struct IconPickerSheet: View {

    // MARK: - Properties

    @Binding var selectedIcon: String
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            IconPicker(selectedIcon: $selectedIcon)
                .padding(AppSpacing.large)
        }
        .navigationTitle(AppString.selectIcon)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(AppString.done) {
                    dismiss()
                }
                .font(.app(.section))
                .foregroundStyle(AppColor.income)
            }
        }
    }
}

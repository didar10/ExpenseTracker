//
//  DataUnavailableView.swift
//  ExpenseTracker
//
//  Created by Didar on 26.10.2026.
//

import SwiftUI

/// Экран вместо приложения, если базу не удалось открыть
struct DataUnavailableView: View {

    // MARK: - Body

    var body: some View {
        ContentUnavailableView {
            Label {
                Text(AppString.dataUnavailableTitle)
            } icon: {
                AppImage.dataUnavailable
            }
        } description: {
            Text(AppString.dataUnavailableMessage)
        }
        .background(AppColor.background)
    }
}

#Preview {
    DataUnavailableView()
}

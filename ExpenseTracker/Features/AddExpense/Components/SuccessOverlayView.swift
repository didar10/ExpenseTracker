//
//  SuccessOverlayView.swift
//  ExpenseTracker
//
//  Created by Didar on 23.01.2026.
//

import SwiftUI

struct SuccessOverlayView: View {

    // MARK: - Properties

    let isShowing: Bool

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                AppImage.checkmarkCircleFill
                    .font(.system(size: 60))
                    .foregroundStyle(AppColor.income)
                    .symbolEffect(.bounce, value: isShowing)

                AppText(AppString.saved, style: .section)
                    .color(AppColor.textPrimary)
            }
            .padding(32)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            }
            .scaleEffect(isShowing ? 1.0 : 0.5)
            .opacity(isShowing ? 1.0 : 0)
        }
    }
}

//
//  SuccessOverlayView.swift
//  ExpenseTracker
//
//  Created by Didar on 23.01.2026.
//

import SwiftUI

struct SuccessOverlayView: View {

    // MARK: - Properties

    @State private var isBounced = false

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColor.scrim
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.large) {
                AppImage.checkmarkCircleFill
                    .font(.system(size: AppSize.glyphHuge))
                    .foregroundStyle(AppColor.income)
                    .symbolEffect(.bounce, value: isBounced)

                AppText(AppString.saved, style: .section)
                    .color(AppColor.textPrimary)
            }
            .padding(AppSpacing.xxxLarge)
            .background {
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AppString.saved)
        .onAppear { isBounced = true }
    }
}

#Preview {
    SuccessOverlayView()
}

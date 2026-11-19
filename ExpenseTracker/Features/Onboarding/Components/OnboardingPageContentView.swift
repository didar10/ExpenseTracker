//
//  OnboardingPageContentView.swift
//  ExpenseTracker
//
//  Created by Didar on 03.09.2026.
//

import SwiftUI

/// Страница приветственного экрана: иконка, заголовок и пояснение.
/// Части появляются по очереди, поэтому взгляд идет сверху вниз
struct OnboardingPageContentView: View {

    // MARK: - Properties

    let page: OnboardingPage
    let isVisible: Bool

    // MARK: - Body

    var body: some View {
        VStack(spacing: AppSpacing.xxxLarge) {
            heroIcon

            textBlock
        }
        .padding(.horizontal, AppSpacing.xLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Subviews

private extension OnboardingPageContentView {

    var heroIcon: some View {
        ZStack {
            Circle()
                .fill(page.accentColor.opacity(Constants.outerCircleOpacity))
                .frame(width: AppSize.onboardingHero, height: AppSize.onboardingHero)

            Circle()
                .fill(page.accentColor.opacity(Constants.innerCircleOpacity))
                .frame(width: AppSize.onboardingHeroInner, height: AppSize.onboardingHeroInner)

            page.icon
                .font(.system(size: AppSize.glyphOnboarding, weight: .semibold))
                .foregroundStyle(page.accentColor)
        }
        .onboardingAppearance(isVisible: isVisible)
        .accessibilityHidden(true)
    }

    var textBlock: some View {
        VStack(spacing: AppSpacing.medium) {
            AppText(page.title, style: .onboardingTitle, alignment: .center)
                .onboardingAppearance(isVisible: isVisible, delay: Constants.titleDelay)

            AppText(
                page.subtitle,
                style: .body,
                color: AppColor.textSecondary,
                alignment: .center
            )
            .onboardingAppearance(isVisible: isVisible, delay: Constants.subtitleDelay)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Constants

private extension OnboardingPageContentView {

    enum Constants {
        static let outerCircleOpacity: Double = 0.1
        static let innerCircleOpacity: Double = 0.16
        static let titleDelay: Double = 0.07
        static let subtitleDelay: Double = 0.14
    }
}

#Preview("Приветствие") {
    OnboardingPageContentView(page: .welcome, isVisible: true)
        .background(AppColor.background)
}

#Preview("Бюджеты") {
    OnboardingPageContentView(page: .budgets, isVisible: true)
        .background(AppColor.background)
}

//
//  OnboardingPageIndicatorView.swift
//  ExpenseTracker
//
//  Created by Didar on 03.09.2026.
//

import SwiftUI

/// Индикатор страниц: активная точка вытягивается в капсулу и берет цвет страницы.
/// Системный индикатор TabView не умеет ни того, ни другого
struct OnboardingPageIndicatorView: View {

    // MARK: - Properties

    let pages: [OnboardingPage]
    let currentPage: OnboardingPage

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.smaller) {
            ForEach(pages) { page in
                Capsule()
                    .fill(fillColor(for: page))
                    .frame(width: width(for: page), height: AppSize.pageIndicatorDot)
            }
        }
        .animation(.spring(response: Constants.response, dampingFraction: Constants.dampingFraction), value: currentPage)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            AppString.onboardingPagePosition(
                current: (pages.firstIndex(of: currentPage) ?? 0) + 1,
                total: pages.count
            )
        )
    }
}

// MARK: - Private Methods

private extension OnboardingPageIndicatorView {

    func width(for page: OnboardingPage) -> CGFloat {
        page == currentPage ? AppSize.pageIndicatorActiveDot : AppSize.pageIndicatorDot
    }

    func fillColor(for page: OnboardingPage) -> Color {
        page == currentPage ? currentPage.accentColor : AppColor.neutralFill
    }
}

// MARK: - Constants

private extension OnboardingPageIndicatorView {

    enum Constants {
        static let response: Double = 0.35
        static let dampingFraction: Double = 0.85
    }
}

#Preview {
    VStack(spacing: AppSpacing.xLarge) {
        OnboardingPageIndicatorView(pages: OnboardingPage.allCases, currentPage: .welcome)
        OnboardingPageIndicatorView(pages: OnboardingPage.allCases, currentPage: .statistics)
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
}

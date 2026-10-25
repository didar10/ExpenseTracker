//
//  OnboardingView.swift
//  ExpenseTracker
//
//  Created by Didar on 03.09.2026.
//

import SwiftUI

/// Приветственный экран при первом запуске: четыре страницы о том,
/// что делает приложение. Листается свайпом или кнопкой, пропускается в один тап
struct OnboardingView: View {

    // MARK: - Properties

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var viewModel: OnboardingViewModel
    /// Появление содержимого после открытия экрана — только на первой странице
    @State private var isContentVisible = false

    // MARK: - Computed Properties

    private var pageAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: Constants.reducedDuration)
            : .spring(response: Constants.pageResponse, dampingFraction: Constants.pageDamping)
    }

    // MARK: - Init

    @MainActor
    init(store: OnboardingStore) {
        _viewModel = State(initialValue: OnboardingViewModel(store: store))
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            skipBar

            pagesView

            footer
        }
        .background(AppColor.background)
        .onAppear { isContentVisible = true }
        .onChange(of: viewModel.currentPage) { _, _ in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}

// MARK: - Subviews

private extension OnboardingView {

    var skipBar: some View {
        HStack {
            Spacer()

            Button(action: handleSkip) {
                AppText(AppString.onboardingSkip, style: .bodySmall, color: AppColor.textSecondary)
                    .padding(.horizontal, AppSpacing.medium)
                    .padding(.vertical, AppSpacing.small)
            }
            .buttonStyle(PressableScaleButtonStyle())
            .opacity(viewModel.isSkipAvailable ? 1 : 0)
            .allowsHitTesting(viewModel.isSkipAvailable)
            .accessibilityHidden(!viewModel.isSkipAvailable)
            .animation(.easeOut(duration: Constants.fadeDuration), value: viewModel.isSkipAvailable)
        }
        .frame(minHeight: AppSize.toolbarButton)
        .padding(.horizontal, AppSpacing.small)
    }

    /// Страницы листаются системным пейджингом: свайп идет за пальцем
    /// и пружинит на краях, чего не дает ручной переключатель
    var pagesView: some View {
        TabView(selection: $viewModel.currentPage) {
            ForEach(viewModel.pages) { page in
                OnboardingPageContentView(
                    page: page,
                    isVisible: page != viewModel.pages.first || isContentVisible
                )
                .tag(page)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    var footer: some View {
        VStack(spacing: AppSpacing.xLarge) {
            OnboardingPageIndicatorView(
                pages: viewModel.pages,
                currentPage: viewModel.currentPage
            )
            .onboardingAppearance(isVisible: isContentVisible, delay: Constants.indicatorDelay)

            PrimaryActionButton(
                title: viewModel.primaryActionTitle,
                action: handlePrimaryAction
            )
            .contentTransition(.opacity)
            .animation(.easeOut(duration: Constants.fadeDuration), value: viewModel.primaryActionTitle)
            .onboardingAppearance(isVisible: isContentVisible, delay: Constants.buttonDelay)
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.top, AppSpacing.large)
        .padding(.bottom, AppSpacing.xxLarge)
    }
}

// MARK: - Actions

private extension OnboardingView {

    /// Смена страницы уже дает отклик в onChange, поэтому здесь он только на завершении
    func handlePrimaryAction() {
        guard !viewModel.isLastPage else {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            viewModel.performPrimaryAction()
            return
        }

        withAnimation(pageAnimation) {
            viewModel.performPrimaryAction()
        }
    }

    func handleSkip() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        viewModel.skip()
    }
}

// MARK: - Constants

private extension OnboardingView {

    enum Constants {
        static let pageResponse: Double = 0.4
        static let pageDamping: Double = 0.9
        static let reducedDuration: Double = 0.2
        static let fadeDuration: Double = 0.18
        static let indicatorDelay: Double = 0.21
        static let buttonDelay: Double = 0.28
    }
}

#Preview {
    OnboardingView(store: OnboardingStore())
}

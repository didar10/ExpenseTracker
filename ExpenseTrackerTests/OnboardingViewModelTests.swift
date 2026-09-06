//
//  OnboardingViewModelTests.swift
//  ExpenseTrackerTests
//

import Foundation
import Testing
@testable import ExpenseTracker

@MainActor
@Suite
struct OnboardingViewModelTests {

    // MARK: - Helpers

    /// Отдельное хранилище на каждый тест, чтобы они не влияли друг на друга
    private func makeStore() -> OnboardingStore {
        OnboardingStore(defaults: UserDefaults(suiteName: "OnboardingTests.\(UUID().uuidString)")!)
    }

    // MARK: - Tests

    @Test func onboardingIsNotCompletedOnFirstLaunch() {
        #expect(makeStore().isCompleted == false)
    }

    @Test func completionIsRestoredOnNextLaunch() {
        let defaults = UserDefaults(suiteName: "OnboardingTests.\(UUID().uuidString)")!

        OnboardingStore(defaults: defaults).complete()

        #expect(OnboardingStore(defaults: defaults).isCompleted)
    }

    @Test func primaryActionMovesToNextPage() {
        let viewModel = OnboardingViewModel(store: makeStore())

        viewModel.performPrimaryAction()

        #expect(viewModel.currentPage == .transactions)
    }

    @Test func primaryActionOnLastPageCompletesOnboarding() {
        let store = makeStore()
        let viewModel = OnboardingViewModel(store: store)
        viewModel.currentPage = .budgets

        viewModel.performPrimaryAction()

        #expect(store.isCompleted)
        #expect(viewModel.currentPage == .budgets)
    }

    @Test func skipCompletesOnboardingFromAnyPage() {
        let store = makeStore()
        let viewModel = OnboardingViewModel(store: store)

        viewModel.skip()

        #expect(store.isCompleted)
    }

    @Test func lastPageChangesButtonTitleAndHidesSkip() {
        let viewModel = OnboardingViewModel(store: makeStore())

        #expect(viewModel.isLastPage == false)
        #expect(viewModel.isSkipAvailable)
        #expect(viewModel.primaryActionTitle == AppString.onboardingNext)

        viewModel.currentPage = .budgets

        #expect(viewModel.isLastPage)
        #expect(viewModel.isSkipAvailable == false)
        #expect(viewModel.primaryActionTitle == AppString.onboardingStart)
    }
}

//
//  OnboardingViewModel.swift
//  ExpenseTracker
//
//  Created by Didar on 03.09.2026.
//

import Foundation

/// ViewModel приветственного экрана: листание страниц и завершение онбординга
@MainActor
@Observable
final class OnboardingViewModel {

    // MARK: - Properties

    /// Открытая страница. Свойство меняет и свайп по TabView, поэтому оно доступно на запись
    var currentPage: OnboardingPage = .welcome

    let pages = OnboardingPage.allCases

    @ObservationIgnored
    private let store: OnboardingStore

    // MARK: - Computed Properties

    var isLastPage: Bool {
        currentPage == pages.last
    }

    /// На последней странице кнопка завершает онбординг, на остальных — листает дальше
    var primaryActionTitle: String {
        isLastPage ? AppString.onboardingStart : AppString.onboardingNext
    }

    /// Пропуск не нужен на последней странице: там кнопка делает то же самое
    var isSkipAvailable: Bool {
        !isLastPage
    }

    // MARK: - Init

    init(store: OnboardingStore) {
        self.store = store
    }

    // MARK: - Actions

    /// Кнопка под индикатором: листает дальше или завершает онбординг
    func performPrimaryAction() {
        guard !isLastPage else {
            complete()
            return
        }

        goToNextPage()
    }

    func skip() {
        complete()
    }

    // MARK: - Private Methods

    private func goToNextPage() {
        let nextIndex = currentPage.rawValue + 1

        guard let nextPage = OnboardingPage(rawValue: nextIndex) else { return }

        currentPage = nextPage
    }

    private func complete() {
        store.complete()
    }
}

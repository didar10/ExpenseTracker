//
//  AppRootView.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import SwiftUI
import SwiftData

struct AppRootView: View {

    // MARK: - Properties

    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var onboardingStore = OnboardingStore()

    // MARK: - Computed Properties

    /// Онбординг уходит от пользователя, приложение приходит из глубины:
    /// переход в одну сторону, вернуться на приветственный экран нельзя
    private var appTransition: AnyTransition {
        reduceMotion
            ? .opacity
            : .opacity.combined(with: .scale(scale: Constants.appEnterScale))
    }

    private var onboardingTransition: AnyTransition {
        reduceMotion
            ? .opacity
            : .opacity.combined(with: .scale(scale: Constants.onboardingExitScale))
    }

    private var transitionAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: Constants.reducedDuration)
            : .spring(response: Constants.response, dampingFraction: Constants.dampingFraction)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            if onboardingStore.isCompleted {
                RootTabView()
                    .transition(appTransition)
            } else {
                OnboardingView(store: onboardingStore)
                    .transition(onboardingTransition)
            }
        }
        .animation(transitionAnimation, value: onboardingStore.isCompleted)
        .task {
            CategorySeeder.seedIfNeeded(context: context)
            AccountSeeder.seedIfNeeded(context: context)
        }
    }
}

// MARK: - Constants

private extension AppRootView {

    enum Constants {
        static let appEnterScale: CGFloat = 0.96
        static let onboardingExitScale: CGFloat = 1.04
        static let response: Double = 0.45
        static let dampingFraction: Double = 1
        static let reducedDuration: Double = 0.2
    }
}

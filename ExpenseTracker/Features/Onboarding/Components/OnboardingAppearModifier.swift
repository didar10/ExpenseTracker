//
//  OnboardingAppearModifier.swift
//  ExpenseTracker
//
//  Created by Didar on 03.09.2026.
//

import SwiftUI

/// Появление элемента приветственного экрана: подъем и проявление с задержкой.
/// Задержки соседних элементов различаются, поэтому блок собирается по частям,
/// а не выезжает целиком. При «Уменьшении движения» остается только проявление
struct OnboardingAppearModifier: ViewModifier {

    // MARK: - Properties

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isVisible: Bool
    var delay: Double = 0

    // MARK: - Computed Properties

    private var animation: Animation {
        reduceMotion
            ? .easeOut(duration: Constants.reducedDuration).delay(delay)
            : .spring(response: Constants.response, dampingFraction: Constants.dampingFraction)
                .delay(delay)
    }

    private var offset: CGFloat {
        guard !reduceMotion, !isVisible else { return .zero }

        return AppSpacing.large
    }

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: offset)
            .animation(animation, value: isVisible)
    }
}

// MARK: - Constants

private extension OnboardingAppearModifier {

    enum Constants {
        static let response: Double = 0.45
        static let dampingFraction: Double = 0.9
        static let reducedDuration: Double = 0.25
    }
}

// MARK: - View

extension View {

    func onboardingAppearance(isVisible: Bool, delay: Double = 0) -> some View {
        modifier(OnboardingAppearModifier(isVisible: isVisible, delay: delay))
    }
}

//
//  BrutalOverlayPresenter.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

/// Показ алерта и меню поверх всего окна — включая таббар и открытые листы.
///
/// Под капотом `fullScreenCover` с прозрачным фоном и без системной анимации:
/// затемнение и появление рисуются здесь же. Действие выбранной кнопки выполняется
/// после закрытия, чтобы из него можно было сразу показать следующий алерт или лист
struct BrutalOverlayPresenter<Overlay: View>: ViewModifier {

    // MARK: - Properties

    @Binding var isPresented: Bool
    /// Контент оверлея получает функцию закрытия: в нее передается действие,
    /// которое выполнится после того, как оверлей исчезнет
    let overlay: (_ dismiss: @escaping (_ then: (() -> Void)?) -> Void) -> Overlay

    @State private var isCoverPresented = false
    @State private var pendingAction: (() -> Void)?

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .onAppear {
                if isPresented { setCover(true) }
            }
            .onChange(of: isPresented) { _, isPresentedNow in
                if isPresentedNow { setCover(true) }
            }
            .fullScreenCover(isPresented: $isCoverPresented, onDismiss: runPendingAction) {
                BrutalOverlayHost(isPresented: $isPresented, onHidden: { setCover(false) }) {
                    overlay { action in
                        pendingAction = action
                        isPresented = false
                    }
                }
                .presentationBackground(.clear)
            }
    }

    // MARK: - Private Methods

    private func setCover(_ isShown: Bool) {
        var transaction = SwiftUI.Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            isCoverPresented = isShown
        }
    }

    private func runPendingAction() {
        let action = pendingAction
        pendingAction = nil
        action?()
    }
}

// MARK: - Host

/// Затемнение и анимация появления/исчезновения
private struct BrutalOverlayHost<Content: View>: View {

    // MARK: - Properties

    @Binding var isPresented: Bool
    let onHidden: () -> Void
    @ViewBuilder let content: Content

    @State private var isVisible = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Body

    var body: some View {
        ZStack {
            DS.Color.scrim
                .ignoresSafeArea()
                .opacity(isVisible ? 1 : .zero)
                .onTapGesture { isPresented = false }
                .accessibilityHidden(true)

            content
                .opacity(isVisible ? 1 : .zero)
                .scaleEffect(isVisible || reduceMotion ? 1 : Constants.hiddenScale)
        }
        .accessibilityAddTraits(.isModal)
        .accessibilityAction(.escape) { isPresented = false }
        .onAppear {
            withAnimation(DS.Motion.overlay) { isVisible = true }
        }
        .onChange(of: isPresented) { _, isPresentedNow in
            guard !isPresentedNow else { return }
            withAnimation(DS.Motion.overlay) {
                isVisible = false
            } completion: {
                onHidden()
            }
        }
    }
}

// MARK: - Constants

private enum Constants {
    static let hiddenScale: CGFloat = 0.96
}

//
//  PressableScaleButtonStyle.swift
//  ExpenseTracker
//
//  Created by Didar on 31.08.2026.
//

import SwiftUI

/// Нажатие ощущается на касании, а не после отпускания: короткое сжатие без отскока.
/// При включенном «Уменьшении движения» масштаб не меняется
struct PressableScaleButtonStyle: ButtonStyle {

    // MARK: - Properties

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var pressedScale: CGFloat = 0.97

    // MARK: - Body

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? pressedScale : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

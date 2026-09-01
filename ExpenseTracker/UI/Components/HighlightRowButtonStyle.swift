//
//  HighlightRowButtonStyle.swift
//  ExpenseTracker
//
//  Created by Didar on 01.09.2026.
//

import SwiftUI

/// Нажатие на строку списка подсвечивается, а не масштабируется:
/// карточка в потоке списка при сжатии «прыгала» бы относительно соседей
struct HighlightRowButtonStyle: ButtonStyle {

    // MARK: - Properties

    var cornerRadius: CGFloat = AppRadius.card

    // MARK: - Body

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppColor.subtleFill)
                    .opacity(configuration.isPressed ? 1 : 0)
            }
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

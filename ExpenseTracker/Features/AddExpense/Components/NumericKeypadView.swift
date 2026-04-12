//
//  NumericKeypadView.swift
//  ExpenseTracker
//
//  Created by Didar on 05.01.2026.
//

import SwiftUI

struct NumericKeypadView: View {

    // MARK: - Types

    enum Key: Hashable {
        case number(String)
        case decimal
        case delete
    }

    // MARK: - Properties

    let isEnterEnabled: Bool
    let onKeyTap: (Key) -> Void
    let onEnterTap: () -> Void

    @State private var pressedKey: Key?

    private let rows: [[Key]] = [
        [.number("1"), .number("2"), .number("3")],
        [.number("4"), .number("5"), .number("6")],
        [.number("7"), .number("8"), .number("9")],
        [.decimal, .number("0"), .delete]
    ]

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { key in
                        keyButton(key)
                    }
                }
            }

            enterButton
        }
    }
}

// MARK: - Subviews
private extension NumericKeypadView {

    func keyButton(_ key: Key) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

            withAnimation(.easeInOut(duration: 0.1)) {
                pressedKey = key
            }

            onKeyTap(key)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    pressedKey = nil
                }
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColor.cardBackground)
                    .shadow(
                        color: AppColor.textPrimary.opacity(pressedKey == key ? 0.3 : 0.65),
                        radius: 0,
                        x: pressedKey == key ? 2 : 4,
                        y: pressedKey == key ? 3 : 6
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(AppColor.textPrimary.opacity(0.15), lineWidth: 1.5)
                    )

                switch key {
                case .number(let value):
                    Text(value)
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColor.textPrimary)
                case .decimal:
                    AppText(".", style: .title)
                case .delete:
                    AppImage.deleteBackward
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(AppColor.expense)
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
        .frame(height: 60)
        .scaleEffect(pressedKey == key ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: pressedKey == key)
    }

    var enterButton: some View {
        Button {
            if isEnterEnabled {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                onEnterTap()
            } else {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        } label: {
            HStack(spacing: 10) {
                AppText(isEnterEnabled ? AppString.save : AppString.enterAmount, style: .section)
                    .color(AppColor.textWhite)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isEnterEnabled ? AppColor.income : AppColor.textTertiary.opacity(0.5))
                    .shadow(
                        color: isEnterEnabled ? AppColor.income.opacity(0.4) : Color.clear,
                        radius: isEnterEnabled ? 10 : 0,
                        y: isEnterEnabled ? 4 : 0
                    )
            }
        }
        .disabled(!isEnterEnabled)
        .padding(.top, 4)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isEnterEnabled)
    }
}

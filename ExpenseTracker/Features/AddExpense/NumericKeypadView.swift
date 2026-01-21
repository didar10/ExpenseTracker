//
//  NumericKeypadView.swift
//  ExpenseTracker
//
//  Created by Didar on 05.01.2026.
//

import SwiftUI

struct NumericKeypadView: View {

    enum Key: Hashable {
        case number(String)
        case decimal
        case delete
    }

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

    // MARK: - Buttons

    private func keyButton(_ key: Key) -> some View {
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
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(
                        color: .black.opacity(pressedKey == key ? 0.3 : 0.65),
                        radius: 0,
                        x: pressedKey == key ? 2 : 4,
                        y: pressedKey == key ? 3 : 6
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.black.opacity(0.15), lineWidth: 1.5)
                    )

                switch key {
                case .number(let value):
                    Text(value)
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                case .decimal:
                    Text(".")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.primary)
                case .delete:
                    Image(systemName: "delete.backward.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.red)
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
        .frame(height: 60)
        .scaleEffect(pressedKey == key ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: pressedKey == key)
    }

    private var enterButton: some View {
        Button {
            if isEnterEnabled {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                onEnterTap()
            } else {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        } label: {
            HStack(spacing: 10) {
                if isEnterEnabled {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .transition(.scale.combined(with: .opacity))
                }
                
                Text(isEnterEnabled ? "Сохранить" : "Введите сумму")
                    .font(.system(size: 18, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isEnterEnabled ? Color.green : Color.gray.opacity(0.5))
                    .shadow(
                        color: isEnterEnabled ? Color.green.opacity(0.4) : Color.clear,
                        radius: isEnterEnabled ? 10 : 0,
                        y: isEnterEnabled ? 4 : 0
                    )
            }
            .foregroundStyle(.white)
        }
        .disabled(!isEnterEnabled)
        .padding(.top, 4)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isEnterEnabled)
    }
}


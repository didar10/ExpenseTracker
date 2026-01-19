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
        VStack(spacing: 10) {

            ForEach(rows, id: \.self) { row in
                HStack(spacing: 10) {
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
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
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
                RoundedRectangle(cornerRadius: 12)
                    .fill(pressedKey == key ? Color(.tertiarySystemBackground) : Color(.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.05), radius: pressedKey == key ? 0 : 2, y: pressedKey == key ? 0 : 1)

                switch key {
                case .number(let value):
                    Text(value)
                        .font(.system(size: 26, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary)
                case .decimal:
                    Text(".")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.primary)
                case .delete:
                    Image(systemName: "delete.backward.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.secondary)
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
        .frame(height: 58)
        .scaleEffect(pressedKey == key ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: pressedKey == key)
    }

    private var enterButton: some View {
        Button {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            onEnterTap()
        } label: {
            HStack(spacing: 8) {
                Text(isEnterEnabled ? "Сохранить" : "Введите сумму")
                    .font(.system(size: 18, weight: .semibold))
                
                if isEnterEnabled {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isEnterEnabled ? 
                          LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                          LinearGradient(colors: [Color(.systemGray4), Color(.systemGray5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: isEnterEnabled ? .green.opacity(0.3) : .clear, radius: 8, y: 4)
            }
            .foregroundStyle(.white)
        }
        .disabled(!isEnterEnabled)
        .padding(.top, 6)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isEnterEnabled)
    }
}


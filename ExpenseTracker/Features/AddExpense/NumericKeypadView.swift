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
            onKeyTap(key)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemBackground))

                switch key {
                case .number(let value):
                    Text(value)
                        .font(.system(size: 22, weight: .semibold))
                case .decimal:
                    Text(".")
                        .font(.system(size: 22, weight: .semibold))
                case .delete:
                    Image(systemName: "delete.left")
                        .font(.system(size: 20))
                }
            }
        }
        .frame(height: 54)
    }

    private var enterButton: some View {
        Button {
            onEnterTap()
        } label: {
            Text("Готово")
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isEnterEnabled ? Color.green : Color.gray)
                )
                .foregroundColor(.white)
        }
        .disabled(!isEnterEnabled)
        .padding(.top, 4)
    }
}


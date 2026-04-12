//
//  IconPicker.swift
//  ExpenseTracker
//
//  Created by Didar on 03.01.2026.
//

import SwiftUI

struct IconPicker: View {

    // MARK: - Properties

    @Binding var selectedIcon: String

    private let icons: [String] = [
        "cart", "cart.fill", "bag", "bag.fill",
        "basket", "creditcard", "creditcard.fill",
        "gift", "gift.fill", "tag",
        "fork.knife", "takeoutbag.and.cup.and.straw",
        "cup.and.saucer", "wineglass", "birthday.cake",
        "house", "house.fill", "sofa.fill",
        "lightbulb", "drop.fill", "flame.fill",
        "car", "car.fill", "bus", "tram",
        "airplane", "fuelpump", "bicycle",
        "heart", "heart.fill", "cross.case",
        "cross.case.fill", "pills.fill",
        "gamecontroller", "gamecontroller.fill",
        "tv", "music.note", "film",
        "graduationcap", "graduationcap.fill",
        "briefcase", "briefcase.fill",
        "book", "book.fill",
        "phone", "wifi", "antenna.radiowaves.left.and.right",
        "bolt.fill", "wrench.and.screwdriver",
        "pawprint", "leaf", "globe",
        "star", "star.fill"
    ]

    // MARK: - Body

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: .init(.flexible()), count: 6),
                spacing: 16
            ) {
                ForEach(icons, id: \.self) { icon in
                    iconCell(icon)
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Subviews
private extension IconPicker {

    func iconCell(_ icon: String) -> some View {
        Image(systemName: icon)
            .font(.title2)
            .frame(width: 44, height: 44)
            .background(
                selectedIcon == icon
                ? AppColor.income.opacity(0.25)
                : AppColor.textSecondary.opacity(0.1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        selectedIcon == icon ? AppColor.income : Color.clear,
                        lineWidth: 2
                    )
            )
            .onTapGesture {
                selectedIcon = icon
            }
    }
}

//
//  IconPicker.swift
//  ExpenseTracker
//
//  Created by Didar on 03.01.2026.
//

import SwiftUI

struct IconPicker: View {

    @Binding var selectedIcon: String

    private let icons: [String] = [

        // Покупки
        "cart", "cart.fill", "bag", "bag.fill",
        "basket", "creditcard", "creditcard.fill",
        "gift", "gift.fill", "tag",

        // Еда
        "fork.knife", "takeoutbag.and.cup.and.straw",
        "cup.and.saucer", "wineglass", "birthday.cake",

        // Дом
        "house", "house.fill", "sofa.fill",
        "lightbulb", "drop.fill", "flame.fill",

        // Транспорт
        "car", "car.fill", "bus", "tram",
        "airplane", "fuelpump", "bicycle",

        // Здоровье
        "heart", "heart.fill", "cross.case",
        "cross.case.fill", "pills.fill",

        // Развлечения
        "gamecontroller", "gamecontroller.fill",
        "tv", "music.note", "film",

        // Образование / работа
        "graduationcap", "graduationcap.fill",
        "briefcase", "briefcase.fill",
        "book", "book.fill",

        // Связь и сервисы
        "phone", "wifi", "antenna.radiowaves.left.and.right",
        "bolt.fill", "wrench.and.screwdriver",

        // Прочее
        "pawprint", "leaf", "globe",
        "star", "star.fill"
    ]

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

    private func iconCell(_ icon: String) -> some View {
        Image(systemName: icon)
            .font(.title2)
            .frame(width: 44, height: 44)
            .background(
                selectedIcon == icon
                ? Color.green.opacity(0.25)
                : Color.secondary.opacity(0.1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        selectedIcon == icon ? Color.green : Color.clear,
                        lineWidth: 2
                    )
            )
            .onTapGesture {
                selectedIcon = icon
            }
    }
}

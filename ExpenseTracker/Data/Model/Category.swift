//
//  Category.swift
//  ExpenseTracker
//
//  Created by Didar on 20.12.2025.
//

import Foundation
import SwiftData

@Model
final class Category {

    @Attribute(.unique)
    var id: UUID

    var name: String
    var icon: String
    var colorHex: String

    init(
        name: String,
        icon: String,
        colorHex: String
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
    }
}

//
//  DS+Icon.swift
//  ExpenseTracker
//
//  Created by Didar on 25.11.2026.
//

import SwiftUI

extension DS {

    /// Служебные иконки компонентов. Иконки категорий и счетов приходят из данных
    enum Icon {
        static let chevronDown = Image(systemName: "chevron.down")
        static let chevronLeft = Image(systemName: "chevron.left")
        static let chevronRight = Image(systemName: "chevron.right")
        static let checkmark = Image(systemName: "checkmark")
        static let plus = Image(systemName: "plus")
        static let backspace = Image(systemName: "delete.left")
        static let search = Image(systemName: "magnifyingglass")
        static let allCategories = Image(systemName: "square.grid.2x2")
        static let noCategory = Image(systemName: "nosign")
        static let close = Image(systemName: "xmark")
        static let trash = Image(systemName: "trash")
        static let calendar = Image(systemName: "calendar")
        static let minus = Image(systemName: "minus")
        static let equal = Image(systemName: "equal")
        /// ⇄ — перевод между счетами
        static let transfer = Image(systemName: "arrow.left.arrow.right")
        static let warning = Image(systemName: "exclamationmark.circle")
    }
}

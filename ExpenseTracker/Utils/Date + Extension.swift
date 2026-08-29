//
//  Date + Extension.swift
//  ExpenseTracker
//
//  Created by Didar on 30.08.2026.
//

import Foundation

extension Date {

    /// Дата относится к текущему календарному году
    var isInCurrentYear: Bool {
        let calendar = Calendar.current
        return calendar.component(.year, from: self) == calendar.component(.year, from: Date())
    }
}

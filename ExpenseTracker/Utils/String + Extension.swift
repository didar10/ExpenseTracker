//
//  String + Extension.swift
//  ExpenseTracker
//
//  Created by Didar on 30.08.2026.
//

import Foundation

extension String {

    /// Поднимает регистр только первой буквы: «август» → «Август», «24—30 авг.» не меняется
    var capitalizingFirstLetter: String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }
}

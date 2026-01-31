//
//  SectionHeaderView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

/// Компонент заголовка секции с датой
struct SectionHeaderView: View {
    let date: Date
    
    var body: some View {
        AppText(dateTitle, style: .bodySmaller)
            .foregroundStyle(.gray)
            .padding(.horizontal, 4)
    }
    
    private var dateTitle: String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Сегодня"
        } else if calendar.isDateInYesterday(date) {
            return "Вчера"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateFormat = "EE, d MMMM"
            return formatter.string(from: date)
        }
    }
}

#Preview("Today") {
    SectionHeaderView(date: Date())
}

#Preview("Yesterday") {
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    return SectionHeaderView(date: yesterday)
}

#Preview("Custom Date") {
    let customDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
    return SectionHeaderView(date: customDate)
}

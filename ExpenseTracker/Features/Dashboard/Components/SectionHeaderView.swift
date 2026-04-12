//
//  SectionHeaderView.swift
//  ExpenseTracker
//
//  Created by Didar on 21.01.2026.
//

import SwiftUI

struct SectionHeaderView: View {

    // MARK: - Properties

    let date: Date

    // MARK: - Body

    var body: some View {
        AppText(dateTitle, style: .bodySmaller)
            .foregroundStyle(AppColor.textTertiary)
            .padding(.horizontal, 4)
    }
}

// MARK: - Private Methods
private extension SectionHeaderView {

    var dateTitle: String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return AppString.today
        } else if calendar.isDateInYesterday(date) {
            return AppString.yesterday
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
